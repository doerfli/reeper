class RecipesController < ApplicationController
  include Secured
  
  def index
    @recipes = Recipe

    if params[:latest_first]
      @recipes = @recipes.order(created_at: :desc)
    else 
      @recipes = @recipes.order(favorite: :desc).order(name: :asc)
    end
    
    @recipes = @recipes.page params[:page]
  end

  def filter_by_tag
    @recipes = Recipe.joins(:tags).where(tags: { id: params[:tagid] }).page params[:page]
    render 'index'
  end

  def search
    logger.debug "Search recipe for #{params[:term]}"
    # @recipes = Recipe.where(ilike(:name, "%#{params[:term]}"))
    if params[:term].nil?
      @recipes = Recipe.all.order_by_name
    else
      name_q = Recipe.arel_table[:name]
      @recipes = Recipe.where(name_q.matches("%#{params[:term]}%"))
    end

    @recipes = @recipes.page params[:page]

    respond_to do |format|
      format.html { render partial: 'list' }
    end
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user_id = session[:userinfo]['id']

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
    params.require(:recipe).permit(:name, :ingredients, :instructions, :duration, :tag_names, :source, :rating)
  end
end
