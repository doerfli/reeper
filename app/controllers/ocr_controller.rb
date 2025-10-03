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
    rotation = params[:rotation]&.to_i || 0
    tmp = Tempfile.new('for_rt')
    recognized_text = ''

    begin
      img = MiniMagick::Image.read(image.download)
      # orient image correctly
      img = img.auto_orient

      # Apply user-specified rotation if provided
      if rotation != 0 && [90, 180, 270].include?(rotation)
        img = img.rotate(rotation)
        logger.debug "Applied rotation: #{rotation} degrees"
      end

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

    cleaned_text = openai_cleanup_service.cleanup(text, prompt)

    render json: { cleaned_text: cleaned_text }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def openai_cleanup_service
    @openai_cleanup_service ||= OpenaiCleanupService.new
  end
end
