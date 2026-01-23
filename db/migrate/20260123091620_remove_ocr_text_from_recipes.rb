class RemoveOcrTextFromRecipes < ActiveRecord::Migration[8.1]
  def change
    remove_column :recipes, :ocr_text, :text
  end
end
