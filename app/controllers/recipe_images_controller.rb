class RecipeImagesController < ApplicationController
  def new
    @recipe = Recipe.find(params[:recipe_id])
  end

  def create
    recipe = Recipe.find(params[:recipe_id])

    if params[:image].nil?
      flash[:error] = t('recipes.images.image_missing')
      redirect_to new_recipe_recipe_image_path(recipe) and return
    end

    recipe.recipe_images.attach(params[:image])
    recipe.save

    redirect_to recipe_path(recipe)
  end

  def delete_select
    @recipe = Recipe.find(params[:recipe_id])
  end

  def delete
    filenames = params[:filenames].split ','
    logger.info filenames
    recipe = Recipe.find(params[:recipe_id])
    images_to_delete = recipe.recipe_images.select{ |i|
      filenames.include?(i.blob.filename.to_s)
    }
    images_to_delete.each{ |i|
      i.purge
    }
    
    redirect_to recipe_path(recipe)
  end
end
