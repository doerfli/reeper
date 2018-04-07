class RecipeImagesController < ApplicationController
  def new
    @recipe = Recipe.find(params[:recipe_id])
  end

  def create
    recipe = Recipe.find(params[:recipe_id])
    recipe.recipe_images.attach(params[:image])
    recipe.save

    redirect_to recipe_path(recipe)
  end
end
