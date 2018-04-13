class TagsController < ApplicationController
  def index
    @tags = if params[:term]
              Tag.match_term params[:term]
            else
              Tag.all
            end

    @tags.joins(:recipes)
    @tags = if params[:term]
              @tags.order(:name)
            else
              Tag.sort_by_recipe_count(@tags)
            end

    respond_to do |format|
      format.html {
        if params[:partial]
          render partial: 'tagslist'
        else
          render
        end
      }
      format.json { render json: @tags.map(&:name) }
    end
  end
end
