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
        # convert jpeg to webp using vips
        tmpfile = Tempfile.new('img', :encoding => 'ascii-8bit')
        im = Vips::Image.new_from_buffer image.read, ""
        tmpfile.write(im.webpsave_buffer(Q: 60))
        tmpfile.close

        webp_filename = image.original_filename.sub(/\.jpg$/, '.webp').sub(/\.jpeg$/, '.webp')

        recipe.recipe_images.attach(
          io: tmpfile.open,
          filename: webp_filename,
          content_type: 'image/webp'
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
