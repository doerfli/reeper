class AddRecipesCountToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :recipes_count, :integer
  end
end
