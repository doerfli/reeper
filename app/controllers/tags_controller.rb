class TagsController < ApplicationController
  def index
    if params[:term]
      @tags = Tag.where("LOWER(name) LIKE ?", "%#{params[:term].downcase}%")
    else
      @tags = Tag.all
    end
    @tags = @tags.order(:name)

    respond_to do |format|
      format.json { render json: @tags.map{ |t| t.name } }
    end
  end
end
