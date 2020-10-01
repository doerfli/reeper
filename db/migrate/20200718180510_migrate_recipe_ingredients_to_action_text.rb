class MigrateRecipeIngredientsToActionText < ActiveRecord::Migration[6.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :recipes, :ingredients, :ingredients_old
    Recipe.all.each do |recipe|
      recipe.update_attribute(:ingredients, simple_format(recipe.ingredients_old))
    end
    remove_column :recipes, :ingredients_old
  end
end
