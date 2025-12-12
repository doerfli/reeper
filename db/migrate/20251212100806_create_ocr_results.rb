class CreateOcrResults < ActiveRecord::Migration[8.1]
  def change
    create_table :ocr_results do |t|
      t.string :result

      t.timestamps
    end
  end
end
