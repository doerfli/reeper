class MistralaiService
  include ImageDataUri
  include RecipeJsonParser

  def initialize
    # API key validation happens at runtime (not initialization) to allow
    # the service to be instantiated even when Mistral AI is not configured.
    # This is intentional - the key is only checked when the service is actually used.
    api_key = ENV['MISTRAL_API_KEY']
    raise "Mistral API key not configured. Set MISTRAL_API_KEY environment variable" if api_key.blank?

    @client = OmniAI::Mistral::Client.new
  end

  def ocr_to_markdown(image_file, content_type)
    filedata = build_data_uri(image_file, content_type)

    response = @client.ocr(filedata, kind: :image)
    recognized_markdown = response.pages[0].markdown

    Rails.logger.debug "Mistral OCR result:\n#{recognized_markdown[0..100]}..."
    recognized_markdown
  end

  def parse_markdown_to_recipes(markdown_text)
    Rails.logger.debug "Sending markdown to Mistral AI API for parsing"

    # Load the system prompt from the file
    system_prompt_file_path = Rails.root.join("config", "prompts", Rails.configuration.mistral.markdown_prompt_file)
    system_prompt = File.read(system_prompt_file_path)

    # Use the client.chat block syntax with system and user prompts
    completion = @client.chat(model: Rails.configuration.mistral.markdown_model) do |chat|
      chat.system(system_prompt)
      chat.user(markdown_text)
    end

    Rails.logger.debug "Mistral AI markdown parsing response: #{completion.text}"

    llm_response_text = completion.text.gsub(/```json/, '').gsub(/```/, '')
    parse_recipes_json(llm_response_text, "Mistral AI markdown parsing", on_error: :raise)
  end

  def parse_url_to_recipes(markdown_text)
    Rails.logger.debug "Sending URL markdown to Mistral AI API for parsing"

    system_prompt_file_path = Rails.root.join("config", "prompts", Rails.configuration.mistral.url_prompt_file)
    system_prompt = File.read(system_prompt_file_path)

    completion = @client.chat(model: Rails.configuration.mistral.url_model) do |chat|
      chat.system(system_prompt)
      chat.user(markdown_text)
    end

    Rails.logger.debug "Mistral AI URL parsing response: #{completion.text}"

    llm_response_text = completion.text.gsub(/```json/, '').gsub(/```/, '')
    parse_recipes_json(llm_response_text, "Mistral AI URL parsing", on_error: :raise)
  end
end
