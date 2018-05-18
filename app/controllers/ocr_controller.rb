class OcrController < ApplicationController
  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    # @recipe = Recipe.find(params[:id])
    # image = @recipe.recipe_images.select{|i| i.id == params[:imgid]}.first
    ri = Recipe.with_attached_recipe_images.find(params[:id]).recipe_images
    image = ri.select { |i| i.id == params[:imgid].to_i }.first
    x1 = params[:x1].to_i
    y1 = params[:y1].to_i
    x2 = params[:x2].to_i
    y2 = params[:y2].to_i
    width = x2 - x1
    height = y2 - y1
    tmp = Tempfile.new('for_rt')
    recognized_text = ''

    begin
      img = MiniMagick::Image.read(image.download)
      img.crop "#{width}x#{height}+#{x1}+#{y1}"
      img.write tmp
      ocrd = RTesseract.new(tmp, processor: 'mini_magick', lang: 'deu')
      # logger.info image.lang
      recognized_text = ocrd.to_s
      logger.info recognized_text
    ensure
      tmp.unlink
    end

    render json: { text: recognized_text }
  end
end
