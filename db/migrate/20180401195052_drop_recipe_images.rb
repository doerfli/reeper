class DropRecipeImages < ActiveRecord::Migration[5.2]
  def change
    drop_table :recipe_images
  end
end
