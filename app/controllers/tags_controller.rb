class TagsController < ApplicationController
  def index
    @tags = Tag.with_recipe
    @tags = Tag.sort_by_recipe_count(@tags)
  end

  def search
    @tags =
      if params[:term]
        Tag.match_term(params[:term]).order(:name)
      else
        Tag.with_recipe.sort_by_recipe_count(Tag.all)
      end

    respond_to do |format|
      format.html { render partial: 'tagslist' }
      format.json { render json: @tags.map(&:name) }
    end
  end
end
