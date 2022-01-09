class PopulateRecipesAndTagsCount < ActiveRecord::Migration[7.0]
  def change
    Tag.all.each { |t|
      t.recipes_count = t.recipes.size
      t.save
    }
  end
end
