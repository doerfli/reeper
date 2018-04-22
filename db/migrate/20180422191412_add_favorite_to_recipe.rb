class AddFavoriteToRecipe < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :favorite, :boolean, default: false
  end
end
