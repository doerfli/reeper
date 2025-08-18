class AddOcrTextToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :ocr_text, :text
  end
end
