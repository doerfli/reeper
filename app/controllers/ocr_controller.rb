class OcrController < ApplicationController
  include Secured

  PAGE_BREAK_MARKER = "\n\n---\n**[NEW SCANNED PAGE]**\n---\n\n"

  def scan
    files = Array(params[:files])
    ai_method = params[:ai_method] || 'mistral_only'
    ocr_flags = build_ocr_flags(files)

    ocr_files = []
    files.each_with_index do |file, index|
      ocr_files << file if ocr_flags[index]
    end

    if ocr_files.empty?
      render json: { success: false, error: I18n.t('ocr.errors.no_images_selected') }
      return
    end

    begin
      files_with_types = ocr_files.map { |f| [f.tempfile, f.content_type] }
      magic_data_json = run_ocr(files_with_types, ai_method)

      if magic_data_json.empty?
        raise "No recipes extracted from image"
      end

      logger.debug "OCR extracted recipes: #{magic_data_json}"

      # Save full OCR result array to database and store id in flash to avoid flash size limits
      ocrresult = OcrResult.create(result: magic_data_json.to_json, ai_method: ai_method)
      ocrresult.image.attach(files.first)
      ocrresult.save

      if files.length > 1
        files[1..].each { |f| ocrresult.extra_images.attach(f) }
      end

      logger.debug "OCR data id stored in flash: #{ocrresult.id}"

      # If multiple recipes detected, redirect to selection page
      if magic_data_json.length > 1
        render json: { success: true, redirect_url: select_recipe_ocr_path(ocrresult.id) }
      else
        # Single recipe, proceed directly to new recipe form
        flash[:ocr_data] = ocrresult.id
        flash[:recipe_index] = 0
        render json: { success: true, redirect_url: new_recipe_path }
      end
    rescue JSON::ParserError => e
      logger.error "OCR JSON parse error: #{e}"
      render json: { success: false, error: I18n.t('ocr.errors.parse_failed') }
    rescue => e
      logger.error "OCR error: #{e.message}"
      render json: { success: false, error: I18n.t('ocr.errors.processing_failed') }
    end
  end

  def cleanup_with_gpt
    text = params[:text]
    language = params[:language] || 'eng'

    prompt = case language
    when 'deu'
      ENV['OPENAI_CLEANUP_PROMPT_DE'] ||
      "Du bist ein Assistent zur OCR-Text-Bereinigung für Rezepte. Der folgende Text wurde mittels OCR aus einem Foto eines Kochbuchs oder einer Kochzeitschrift erkannt und enthält wahrscheinlich Rezepte, Zutaten oder Kochanweisungen. Bitte bereinige den Text, indem du Rechtschreibfehler korrigierst, die Formatierung verbesserst und den Text lesbarer machst, während du die ursprüngliche Bedeutung beibehältst. Achte besonders auf typische Küchenbegriffe, Mengenangaben und Zubereitungsschritte. WICHTIG: Füge niemals neue Anweisungen oder Zutaten hinzu, die nicht im ursprünglichen Text stehen. Wenn bei Zutaten die Mengenangabe unklar ist, markiere sie mit ?Menge?. Antworte auf Deutsch:"
    when 'eng'
      ENV['OPENAI_CLEANUP_PROMPT_EN'] ||
      "You are an OCR text cleanup assistant for recipes. The following text was recognized via OCR from a photo of a cookbook or cooking magazine and likely contains recipes, ingredients, or cooking instructions. Please clean up the text by fixing spelling errors, improving formatting, and making it more readable while preserving the original meaning. Pay special attention to typical cooking terms, measurements, and preparation steps. IMPORTANT: Never add new instructions or ingredients that are not in the original text. When cleaning up ingredients, if the amount is unclear, mark it with ?amount?. Respond in English:"
    else
      ENV['OPENAI_CLEANUP_PROMPT_EN'] ||
      "You are an OCR text cleanup assistant for recipes. The following text was recognized via OCR from a photo of a cookbook or cooking magazine and likely contains recipes, ingredients, or cooking instructions. Please clean up the text by fixing spelling errors, improving formatting, and making it more readable while preserving the original meaning. Pay special attention to typical cooking terms, measurements, and preparation steps. IMPORTANT: Never add new instructions or ingredients that are not in the original text. When cleaning up ingredients, if the amount is unclear, mark it with ?amount?:"
    end

    cleaned_text = openai_service.cleanup(text, prompt)

    render json: { cleaned_text: cleaned_text }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def select_image_for_reparse
    @recipe = Recipe.find(params[:id])
    @page_title = I18n.t('recipes.select_image_for_reparse.title')
  end

  def show_recipe_selection
    @ocr_result = OcrResult.find(params[:id])
    @recipes = JSON.parse(@ocr_result.result)
    @page_title = I18n.t('ocr.select_recipe.title')
    # Get reparse_recipe_id from flash if present (will be consumed after this request)
    @reparse_recipe_id = flash[:reparse_recipe_id]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('ocr.errors.not_found')
    redirect_to recipes_path
  rescue JSON::ParserError => e
    logger.error "Error parsing OCR result: #{e.message}"
    flash[:error] = I18n.t('ocr.errors.parse_failed')
    redirect_to recipes_path
  end

  def select_recipe
    ocr_result_id = params[:ocr_result_id]
    recipe_index = params[:recipe_index].to_i
    reparse_recipe_id = params[:reparse_recipe_id]

    # Validate recipe_index, default to 0 if invalid
    recipe_index = 0 if recipe_index < 0

    # Store both values in flash
    flash[:ocr_data] = ocr_result_id
    flash[:recipe_index] = recipe_index

    # Check if this is a reparse flow
    if reparse_recipe_id.present?
      redirect_to edit_recipe_path(reparse_recipe_id)
    else
      redirect_to new_recipe_path
    end
  end

  def reparse_image
    @recipe = Recipe.find(params[:id])
    attachment_id = params[:attachment_id]
    ai_method = params[:ai_method] || 'mistral_only'

    begin
      # Find the selected image attachment
      attachment = @recipe.recipe_images.find(attachment_id)

      # Download the image blob and get content type
      blob = attachment.blob
      image_file = blob.download
      content_type = blob.content_type

      # Create a temporary file for the AI service
      temp_file = Tempfile.new(['recipe_image', File.extname(blob.filename.to_s)])
      temp_file.binmode
      temp_file.write(image_file)
      temp_file.rewind

      magic_data_json = run_ocr([[temp_file, content_type]], ai_method)

      if magic_data_json.empty?
        raise "No recipes extracted from image"
      end

      # Save full OCR result array to database
      ocrresult = OcrResult.create(result: magic_data_json.to_json, ai_method: ai_method)
      ocrresult.image.attach(blob)
      ocrresult.save

      logger.debug "Reparse OCR data id stored: #{ocrresult.id}"

      # If multiple recipes detected, redirect to selection page
      if magic_data_json.length > 1
        flash[:reparse_recipe_id] = @recipe.id
        redirect_to select_recipe_ocr_path(ocrresult.id)
      else
        # Single recipe, proceed directly to edit form
        flash[:ocr_data] = ocrresult.id
        flash[:recipe_index] = 0
        redirect_to edit_recipe_path(@recipe)
      end
    rescue JSON::ParserError => e
      logger.error "Reparse JSON parse error: #{e.message}"
      flash[:error] = I18n.t('ocr.errors.parse_failed')
      redirect_to recipe_path(@recipe)
    rescue => e
      logger.error "Reparse error: #{e.message}"
      flash[:error] = I18n.t('ocr.errors.processing_failed')
      redirect_to recipe_path(@recipe)
    ensure
      temp_file&.close
      temp_file&.unlink
    end
  end

  private

  # Runs the selected AI pipeline across one or more images and returns the extracted recipes array.
  # files_with_types is an array of [tempfile, content_type] pairs.
  def run_ocr(files_with_types, ai_method)
    case ai_method
    when 'mistral_only'
      run_mistral_only(files_with_types)
    when 'mistral_openai'
      run_mistral_then_openai(files_with_types)
    else
      run_openai_direct(files_with_types)
    end
  end

  # Two-phase: Mistral OCR on every image -> combined markdown parsed by Mistral.
  def run_mistral_only(files_with_types)
    markdown = combined_ocr_markdown(files_with_types)
    mistral_service.parse_markdown_to_recipes(markdown)
  end

  # Two-phase: Mistral OCR on every image -> combined markdown parsed by OpenAI.
  def run_mistral_then_openai(files_with_types)
    markdown = combined_ocr_markdown(files_with_types)
    openai_service.parse_markdown_to_recipes(markdown)
  end

  # Direct OpenAI OCR: all images are sent in a single vision request.
  def run_openai_direct(files_with_types)
    openai_service.ocr_multi(files_with_types)
  end

  # Runs Mistral OCR on each image in turn, then joins the resulting markdown
  # pages into one document (separated by PAGE_BREAK_MARKER) for a single parse step.
  def combined_ocr_markdown(files_with_types)
    markdowns = []

    files_with_types.each_with_index do |(tempfile, content_type), index|
      markdown = mistral_service.ocr_to_markdown(tempfile, content_type)

      if markdown.blank?
        raise "Mistral OCR returned empty markdown for image #{index + 1}"
      end

      markdowns << markdown
    end

    markdowns.join(PAGE_BREAK_MARKER)
  end

  # Builds a boolean array (same length/order as files) indicating which files should be sent for OCR.
  # Missing or absent ocr_flags default to true (include all), preserving behavior for callers that
  # don't send the flag (e.g. the single-image reparse flow, or older clients).
  def build_ocr_flags(files)
    raw_flags = Array(params[:ocr_flags])
    return Array.new(files.length, true) if raw_flags.empty?

    flags = []
    files.each_index do |index|
      flag = raw_flags[index]
      flags << (flag.nil? || ActiveModel::Type::Boolean.new.cast(flag))
    end
    flags
  end

  def openai_service
    @openai_service ||= OpenaiService.new
  end

  def mistral_service
    @mistral_service ||= MistralaiService.new
  end
end
