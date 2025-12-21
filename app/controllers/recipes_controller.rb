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
    @suggested_tags = nil

    # Check for OCR data in session and pre-populate
    logger.debug "OCR data in flash: #{flash[:ocr_data]}"
    if flash[:ocr_data].present?
      ocr_data_id = flash[:ocr_data]
      recipe_index = flash[:recipe_index] || 0
      @ocrresult = OcrResult.find_by(id: ocr_data_id)
      if @ocrresult.present?
        parsed_recipes = JSON.parse(@ocrresult.result)
        ocr_data = parsed_recipes[recipe_index]
        @recipe.name = ocr_data['title'] if ocr_data['title'].present?
        @recipe.ingredients = format_ingredients_as_html(ocr_data['ingredients']) if ocr_data['ingredients'].present?
        @recipe.instructions = format_steps_as_html(ocr_data['steps']) if ocr_data['steps'].present?
        # Extract suggested tags from OCR data
        if ocr_data['tags'].present? && ocr_data['tags'].is_a?(Array)
          tags = ocr_data['tags'].reject { |tag| tag == '[not found]' || tag.blank? }
          @suggested_tags = tags if tags.any?
        end
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
    @ocrresult = nil
    @suggested_tags = nil

    # Check for OCR data in session and pre-populate
    logger.debug "OCR data in flash: #{flash[:ocr_data]}"
    if flash[:ocr_data].present?
      ocr_data_id = flash[:ocr_data]
      recipe_index = flash[:recipe_index] || 0
      @ocrresult = OcrResult.find_by(id: ocr_data_id)
      if @ocrresult.present?
        parsed_recipes = JSON.parse(@ocrresult.result)

        # Validate recipe_index bounds
        if recipe_index >= 0 && recipe_index < parsed_recipes.length
          ocr_data = parsed_recipes[recipe_index]
          @recipe.name = ocr_data['title'] if ocr_data['title'].present?
          @recipe.ingredients = format_ingredients_as_html(ocr_data['ingredients']) if ocr_data['ingredients'].present?
          @recipe.instructions = format_steps_as_html(ocr_data['steps']) if ocr_data['steps'].present?
          # Extract suggested tags from OCR data
          if ocr_data['tags'].present? && ocr_data['tags'].is_a?(Array)
            tags = ocr_data['tags'].reject { |tag| tag == '[not found]' || tag.blank? }
            @suggested_tags = tags if tags.any?
          end
          flash.now[:warning] = I18n.t('ocr.warnings.ai_generated_data')
        else
          logger.error "Invalid recipe index: #{recipe_index} for #{parsed_recipes.length} recipes"
          flash.now[:error] = I18n.t('ocr.errors.invalid_recipe_index')
        end
      end
    end
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

  def reparse_image
    @recipe = Recipe.find(params[:id])
    attachment_id = params[:attachment_id]

    begin
      # Find the selected image attachment
      attachment = @recipe.recipe_images.find(attachment_id)

      # Download the image blob and get content type
      blob = attachment.blob
      image_file = blob.download
      content_type = blob.content_type

      # Create a temporary file for the OpenAI service
      temp_file = Tempfile.new(['recipe_image', File.extname(blob.filename.to_s)])
      temp_file.binmode
      temp_file.write(image_file)
      temp_file.rewind

      # Call OpenAI service to parse the image
      openai = OpenaiService.new
      magic_data_json = openai.ocr(temp_file, content_type)

      # Save OCR result to database
      ocrresult = OcrResult.create(result: magic_data_json.to_s)
      ocrresult.image.attach(blob)
      ocrresult.save
      flash[:ocr_data] = ocrresult.id

      logger.debug "Reparse OCR data id stored in flash: #{flash[:ocr_data]}"

      redirect_to edit_recipe_path(@recipe)
    rescue JSON::ParserError => e
      logger.error "Reparse JSON parse error: #{e.message}"
      flash[:error] = I18n.t('ocr.errors.parse_failed')
      redirect_to recipe_path(@recipe)
    rescue => e
      logger.error "Reparse error: #{e.message}"
      flash[:error] = I18n.t('ocr.errors.processing_failed')
      redirect_to recipe_path(@recipe)
    ensure
      temp_file&.close
      temp_file&.unlink
    end
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
