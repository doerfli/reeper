class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all.order('LOWER(name), id')
  end

  def new
    @recipe = Recipe.new
  end

  def create
    recipe = Recipe.new(recipe_params)
    recipe.save

    redirect_to action: :show, id: recipe
  end

  def show
    @recipe = Recipe.find(params[:id])
    @page_title = @recipe.name
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @page_title = @recipe.name
  end

  def update
    recipe = Recipe.find(params[:id])
    recipe.update(recipe_params)
    recipe.save
    redirect_to action: :show, id: recipe
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy()

    render json: { redirect_url: recipes_path }
  end

  private
    def recipe_params
      params.require(:recipe).permit(:name, :ingredients, :instructions, :duration, :tag_names)
    end
end
