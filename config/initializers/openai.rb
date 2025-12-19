Rails.application.configure do
  config.openai = ActiveSupport::OrderedOptions.new
  config.openai.recipe_ocr_prompt_id = ENV.fetch('OPENAI_PROMPT_ID', 'pmpt_69389bf4c7a481909d47bcf85f423781063a569321686620')
  config.openai.recipe_ocr_prompt_version = ENV.fetch('OPENAI_PROMPT_VERSION', '9')
end
