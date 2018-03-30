class CreateJoinTableRecipeTags < ActiveRecord::Migration[5.2]
  def change
    create_join_table :recipes, :tags do |t|
      t.index [:recipe_id, :tag_id]
      t.index [:tag_id, :recipe_id]
    end
  end
end
