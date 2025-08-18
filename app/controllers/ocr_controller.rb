class OcrController < ApplicationController
  include Secured
  
  def show
    @recipe = Recipe.find(params[:id])

    render layout: 'layouts/application_wide'
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

    render json: { text: recognized_text }
  end

  def append_to_instructions
    recipe = Recipe.find(params[:id])
    text_to_append = params[:text]
    
    current_instructions = recipe.instructions.to_s
    updated_instructions = current_instructions.blank? ? text_to_append : "#{current_instructions}\n\n#{text_to_append}"
    
    recipe.update(instructions: updated_instructions)
    
    render json: { success: true, message: 'Text appended to instructions' }
  end

  def append_to_ingredients
    recipe = Recipe.find(params[:id])
    text_to_append = params[:text]
    
    current_ingredients = recipe.ingredients.to_s
    updated_ingredients = current_ingredients.blank? ? text_to_append : "#{current_ingredients}\n\n#{text_to_append}"
    
    recipe.update(ingredients: updated_ingredients)
    
    render json: { success: true, message: 'Text appended to ingredients' }
  end
end
