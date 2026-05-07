Rails.application.configure do
  mistral_markdown_model = 'mistral-small-latest'
  mistral_markdown_prompt_file = 'mistral_markdown.txt'

  config.mistral = ActiveSupport::OrderedOptions.new
  config.mistral.markdown_model = ENV.fetch('MISTRAL_MARKDOWN_MODEL', mistral_markdown_model)
  config.mistral.markdown_prompt_file = ENV.fetch('MISTRAL_MARKDOWN_PROMPT_FILE', mistral_markdown_prompt_file)
end
