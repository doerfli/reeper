class TagsController < ApplicationController
  def index
    @tags = if params[:term]
              Tag.match_term params[:term]
            else
              Tag.all
            end

    @tags.joins(:recipes)
    @tags = @tags.sort do |a, b|
      sa = a.recipes.size
      sb = b.recipes.size
      sb <=> sa
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
