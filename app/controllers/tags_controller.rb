class TagsController < ApplicationController
  def index
    @tags = Tag.with_recipes
    @tags = Tag.sort_by_recipe_count(@tags)
  end

  def search
    @tags =
      if params[:term]
        Tag.match_term(params[:term]).order(:name)
      else
        Tag.sort_by_recipe_count(Tag.with_recipes)
      end

    respond_to do |format|
      format.html { render partial: 'tagslist' }
      format.json { render json: @tags.map(&:name) }
    end
  end
end
