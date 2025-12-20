Rails.application.configure do
  openai_prompt_id = 'pmpt_694514e453388194a1e4c121407ef02204bec5d20e21b070'
  openai_prompt_version = '2'

  config.openai = ActiveSupport::OrderedOptions.new
  config.openai.recipe_ocr_prompt_id = ENV.fetch('OPENAI_PROMPT_ID', openai_prompt_id)
  config.openai.recipe_ocr_prompt_version = ENV.fetch('OPENAI_PROMPT_VERSION', openai_prompt_version)
end
