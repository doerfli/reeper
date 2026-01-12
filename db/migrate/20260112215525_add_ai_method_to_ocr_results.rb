class AddAiMethodToOcrResults < ActiveRecord::Migration[8.1]
  def change
    add_column :ocr_results, :ai_method, :string, default: 'openai_direct'
  end
end
