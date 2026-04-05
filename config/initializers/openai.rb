Rails.application.configure do
  openai_prompt_ocr_id = 'pmpt_694514e453388194a1e4c121407ef02204bec5d20e21b070'
  openai_prompt_ocr_version = '2'
  openai_prompt_markdown_id = 'pmpt_69beaa47d824819380be066549da3ff70c095f694abc2646'
  openai_prompt_markdown_version = '2'
  openai_prompt_url_id = 'pmpt_69d267704ec48196a5516098aa55cc1a0678b7f982fe8bcf'
  openai_prompt_url_version = '3'

  config.openai = ActiveSupport::OrderedOptions.new
  config.openai.recipe_ocr_prompt_id = ENV.fetch('OPENAI_PROMPT_OCR_ID', openai_prompt_ocr_id)
  config.openai.recipe_ocr_prompt_version = ENV.fetch('OPENAI_PROMPT_OCR_VERSION', openai_prompt_ocr_version)
  config.openai.recipe_markdown_prompt_id = ENV.fetch('OPENAI_MARKDOWN_PROMPT_ID', openai_prompt_markdown_id)
  config.openai.recipe_markdown_prompt_version = ENV.fetch('OPENAI_MARKDOWN_PROMPT_VERSION', openai_prompt_markdown_version)
  config.openai.recipe_url_prompt_id = ENV.fetch('OPENAI_URL_PROMPT_ID', openai_prompt_url_id)
  config.openai.recipe_url_prompt_version = ENV.fetch('OPENAI_URL_PROMPT_VERSION', openai_prompt_url_version)
end
