require 'vips'

class RecipeImagesController < ApplicationController
  include Secured

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @page_title = @recipe.name
  end

  def create
    recipe = Recipe.find(params[:recipe_id])

    if params[:image].nil?
      flash[:error] = t('recipes.images.image_missing')
      redirect_to new_recipe_recipe_image_path(recipe) and return
    end

    params[:image].each{ |image|
      if image.content_type == "image/jpeg"
        # downgrade image quality to 60 to reduce size of image
        # img = MiniMagick::Image.read(image.read)
        # img.quality(60)
        # tmpfile = Tempfile.new('img')
        # img.write(tmpfile)
        # tmpfile.close
        im = Vips::Image.new_from_file "./10x10.tif"  # "./10x10.jpg"

        recipe.recipe_images.attach(
          io: tmpfile.open,
          filename: image.original_filename,
          content_type: image.content_type
        )
        tmpfile.unlink
      else
        recipe.recipe_images.attach(image)
      end

    }

    recipe.save

    redirect_to recipe_path(recipe)
  end

  def delete_select
    @recipe = Recipe.find(params[:recipe_id])
    @page_title = @recipe.name
  end

  def delete
    filenames = params[:filenames].split ','
    logger.info filenames
    recipe = Recipe.find(params[:recipe_id])
    images_to_delete = recipe.recipe_images.select{ |i|
      filenames.include?(i.blob.filename.to_s)
    }
    images_to_delete.each{ |i|
      i.purge
    }

    redirect_to recipe_path(recipe)
  end
end
