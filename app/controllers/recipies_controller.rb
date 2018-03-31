class RecipiesController < ApplicationController

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
  end

  def create
    recipe = Recipe.new(recipe_params)
    recipe.save

    redirect_to action: :index
  end

  private
    def recipe_params
      params.require(:recipe).permit(:name, :ingredients, :instructions, :duration)
    end

end
