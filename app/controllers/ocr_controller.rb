class OcrController < ApplicationController
  include Secured

  def show
    @recipe = Recipe.find(params[:id])

    render layout: 'layouts/application_wide'
  end

  def create
    recipe = Recipe.find(params[:id])
    ri = recipe.recipe_images
    image = ri.select { |i| i.id == params[:imgid].to_i }.first
    x1 = params[:x1].to_i
    y1 = params[:y1].to_i
    x2 = params[:x2].to_i
    y2 = params[:y2].to_i
    width = x2 - x1
    height = y2 - y1
    language = params[:language]
    tmp = Tempfile.new('for_rt')
    recognized_text = ''

    begin
      img = MiniMagick::Image.read(image.download)
      # orient image correctly
      img = img.auto_orient
      croparea = "#{width}x#{height}+#{x1}+#{y1}"
      logger.debug "croparea #{croparea}"
      img = img.crop croparea
      img.write tmp
      ocrd = RTesseract.new(tmp.path, processor: 'mini_magick', lang: language)
      recognized_text = ocrd.to_s.strip
      logger.info recognized_text
    ensure
      tmp.unlink
    end

    render json: { text: recognized_text, success: true }
  end

  def save_text
    recipe = Recipe.find(params[:id])
    text_to_save = params[:text]

    # Prepend to existing OCR text with timestamp (latest on top)
    timestamp = Time.current.strftime("%Y-%m-%d %H:%M")
    existing_ocr = recipe.ocr_text || ''
    updated_ocr = existing_ocr.blank? ?
      "#{timestamp}:\n#{text_to_save}" :
      "#{timestamp}:\n#{text_to_save}\n\n#{existing_ocr}"

    recipe.update(ocr_text: updated_ocr)
    recipe.save

    render json: { success: true, message: 'Text saved to recipe' }
  end

  def scan
    # Process only the first uploaded file
    file = params[:files].first
    ai_method = params[:ai_method] || 'openai_direct'

    begin
      # Process based on selected AI method
      magic_data_json = if ai_method == 'mistral_openai'
        # Two-phase: Mistral OCR -> OpenAI parsing
        mistral_service = MistralaiService.new
        markdown = mistral_service.ocr_to_markdown(file.tempfile, file.content_type)

        if markdown.blank?
          raise "Mistral OCR returned empty markdown"
        end

        openai_service.parse_markdown_to_recipes(markdown)
      else
        # Direct OpenAI OCR
        openai_service.ocr(file.tempfile, file.content_type)
      end

      if magic_data_json.empty?
        raise "No recipes extracted from image"
      end

      logger.debug "OCR extracted recipes: #{magic_data_json}"

      # Save full OCR result array to database and store id in flash to avoid flash size limits
      ocrresult = OcrResult.create(result: magic_data_json.to_json, ai_method: ai_method)
      ocrresult.image.attach(file)
      ocrresult.save

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
    # rescue => e
    #   logger.error "OCR error: #{e.s}"
    #   render json: { success: false, error: I18n.t('ocr.errors.processing_failed') }
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
    ai_method = params[:ai_method] || 'openai_direct'

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

      # Process based on selected AI method
      magic_data_json = if ai_method == 'mistral_openai'
        # Two-phase: Mistral OCR -> OpenAI parsing
        mistral_service = MistralaiService.new
        markdown = mistral_service.ocr_to_markdown(temp_file, content_type)

        if markdown.blank?
          raise "Mistral OCR returned empty markdown"
        end

        openai_service.parse_markdown_to_recipes(markdown)
      else
        # Direct OpenAI OCR
        openai_service.ocr(temp_file, content_type)
      end

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

  def openai_service
    @openai_service ||= OpenaiService.new
  end

  def mistral_service
    @mistral_service ||= MistralaiService.new
  end
end
