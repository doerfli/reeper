class AddSourceUrlToOcrResults < ActiveRecord::Migration[8.1]
  def change
    add_column :ocr_results, :source_url, :string
  end
end
