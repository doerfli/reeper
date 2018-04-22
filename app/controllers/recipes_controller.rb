class RecipesController < ApplicationController
  def index
    @recipes = Recipe.order("favorite desc").order_by_name
  end

  def filter_by_tag
    @recipes = Recipe.joins(:tags).where(tags: { id: params[:tagid] })
    render 'index'
  end

  def search
    logger.debug "Search recipe for #{params[:term]}"
    # @recipes = Recipe.where(ilike(:name, "%#{params[:term]}"))
    if params[:term].nil?
      @recipes = Recipe.all
    else
      name_q = Recipe.arel_table[:name]
      @recipes = Recipe.where(name_q.matches("%#{params[:term]}%"))
    end

    respond_to do |format|
      format.html { render partial: 'list' }
    end
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)

    unless @recipe.valid?
      flash.now[:error] = @recipe.errors.messages.map{ |k,v|
        v
      }.join(',')
      render :new and return
    end

    @recipe.save

    redirect_to action: :show, id: @recipe.id
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

  def favorite
    recipe = Recipe.find(params[:id])
    recipe.favorite = !recipe.favorite
    recipe.save
    render json: { redirect_url: recipe_path(recipe.id) }
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy()

    render json: { redirect_url: recipes_path }
  end

  private
    def recipe_params
      params.require(:recipe).permit(:name, :ingredients, :instructions, :duration, :tag_names, :source)
    end
end
