Rails.application.configure do
  openai_default_model = 'gpt-5.4-nano'

  config.openai = ActiveSupport::OrderedOptions.new
  config.openai.recipe_ocr_model = ENV.fetch('OPENAI_OCR_MODEL', openai_default_model)
  config.openai.recipe_ocr_prompt_file = ENV.fetch('OPENAI_OCR_PROMPT_FILE', 'openai_ocr.txt')
  config.openai.recipe_markdown_model = ENV.fetch('OPENAI_MARKDOWN_MODEL', openai_default_model)
  config.openai.recipe_markdown_prompt_file = ENV.fetch('OPENAI_MARKDOWN_PROMPT_FILE', 'openai_markdown.txt')
  config.openai.recipe_url_model = ENV.fetch('OPENAI_URL_MODEL', openai_default_model)
  config.openai.recipe_url_prompt_file = ENV.fetch('OPENAI_URL_PROMPT_FILE', 'openai_url.txt')
end
