class RecipeImagesController < ApplicationController
  def new
    @recipe = Recipe.find(params[:recipe_id])
  end

  def create
    recipe = Recipe.find(params[:recipe_id])

    if params[:image].nil?
      flash[:error] = t('recipes.images.image_missing')
      redirect_to new_recipe_recipe_image_path(recipe)
      return
    end

    recipe.recipe_images.attach(params[:image])
    recipe.save

    redirect_to recipe_path(recipe)
  end
end
