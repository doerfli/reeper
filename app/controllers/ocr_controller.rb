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
end
