class OcrController < ApplicationController
  def show
    @recipe = Recipe.find(params[:id])
  end

  def create
    @recipe = Recipe.find(params[:id])
    image = @recipe.recipe_images.select{|i| i.id == params[:imgid]}.first
    tmp = Tempfile.new('for_rt')
    tmp.write(i.download.force_encoding("UTF-8"))
    tmp.close

    # TODO crop image to coordinates

    image = RTesseract.new(tmp, processor: 'mini_magick', lang: 'deu')
    logger.info image.lang
    logger.info image.to_s
    tmp.unlink
  end
end
