class CreateRecipeImages < ActiveRecord::Migration[5.2]
  def change
    create_table :recipe_images do |t|
      t.string :filename
      t.references :recipe, foreign_key: true

      t.timestamps
    end
  end
end
