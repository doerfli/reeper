Rails.application.configure do
  openai_prompt_ocr_id = 'pmpt_694514e453388194a1e4c121407ef02204bec5d20e21b070'
  openai_prompt_ocr_version = '2'
  openai_prompt_markdown_id = 'pmpt_696554b87ef88190bbc1156b6c5fe84f0050d5451e60ae6c'
  openai_prompt_markdown_version = '2'

  config.openai = ActiveSupport::OrderedOptions.new
  config.openai.recipe_ocr_prompt_id = ENV.fetch('OPENAI_PROMPT_OCR_ID', openai_prompt_ocr_id)
  config.openai.recipe_ocr_prompt_version = ENV.fetch('OPENAI_PROMPT_OCR_VERSION', openai_prompt_ocr_version)
  config.openai.recipe_markdown_prompt_id = ENV.fetch('OPENAI_MARKDOWN_PROMPT_ID', openai_prompt_markdown_id)
  config.openai.recipe_markdown_prompt_version = ENV.fetch('OPENAI_MARKDOWN_PROMPT_VERSION', openai_prompt_markdown_version)
end
