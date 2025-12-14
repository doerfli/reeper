class RecipesController < ApplicationController
  include Secured

  def index
    @recipes = Recipe

    if params[:latest_first]
      @recipes = @recipes.order(created_at: :desc)
    elsif params[:rating]
      @recipes = @recipes.where(rating: params[:rating]).order(name: :asc)
    elsif params[:rating_null]
      @recipes = @recipes.where(rating: nil).order(name: :asc)
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
    @ocrresult = nil

    # Check for OCR data in session and pre-populate
    logger.debug "OCR data in flash: #{flash[:ocr_data]}"
    if flash[:ocr_data].present?
      ocr_data_id = flash[:ocr_data]
      @ocrresult = OcrResult.find_by(id: ocr_data_id)
      if @ocrresult.present?
        ocr_data = JSON.parse(@ocrresult.result)
        @recipe.name = ocr_data['title'] if ocr_data['title'].present?
        @recipe.ingredients = format_ingredients_as_html(ocr_data['ingredients']) if ocr_data['ingredients'].present?
        @recipe.instructions = format_steps_as_html(ocr_data['steps']) if ocr_data['steps'].present?
        flash.now[:warning] = I18n.t('ocr.warnings.ai_generated_data')
      end
    end
  end

  def new_magic
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user_id = session[:userinfo]['id']

    if (params[:ocrresult_id].present?)
      ocrresult = OcrResult.find_by(id: params[:ocrresult_id])
      if ocrresult.present?
        @recipe.recipe_images.attach(ocrresult.image.blob) if ocrresult.image.attached?
      end
    end

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

    respond_to do |format|
      format.html
      format.json {
        render json: @recipe.as_json(
          only: [:id, :name, :duration, :source, :rating, :ocr_text]
        )
      }
    end
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @page_title = @recipe.name
  end

  def update
    recipe = Recipe.find(params[:id])
    recipe.update(recipe_params)
    recipe.save

    respond_to do |format|
      format.html { redirect_to action: :show, id: recipe }
      format.json { render json: { success: true, message: 'Recipe updated successfully' } }
    end
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
    params.require(:recipe).permit(:name, :ingredients, :instructions, :duration, :tag_names, :source, :rating, :ocr_text)
  end

  def format_ingredients_as_html(ingredients)
    return '' if ingredients.blank?

    items = ingredients.map { |item| "<li>#{ERB::Util.html_escape(item)}</li>" }.join
    "<ul>#{items}</ul>"
  end

  def format_steps_as_html(steps)
    return '' if steps.blank?

    items = steps.map { |step| "<li>#{ERB::Util.html_escape(step)}</li>" }.join
    "<ol>#{items}</ol>"
  end
end
