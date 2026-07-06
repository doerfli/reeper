class OpenaiService
  def initialize
    # Try environment variable first, fallback to credentials for development
    api_key = ENV['OPENAI_API_KEY']
    raise "OpenAI API key not configured. Set OPENAI_API_KEY environment variable" if api_key.blank?

    @client = OpenAI::Client.new(
      access_token: api_key,
      log_errors: true
    )
  end

  def cleanup(text, prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: prompt },
          { role: "user", content: text }
        ],
        max_tokens: 2000,
        temperature: 0.3
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  def ocr(image_file, content_type)
    ocr_multi([[image_file, content_type]])
  end

  def ocr_multi(image_files_with_types)
    image_blocks = image_files_with_types.map { |image_file, content_type| build_image_content_block(image_file, content_type) }

    model = Rails.configuration.openai.recipe_ocr_model
    system_prompt = File.read(Rails.root.join("config", "prompts", Rails.configuration.openai.recipe_ocr_prompt_file))
    prompt_text = if image_blocks.length > 1
      "Extract all data from these images. They are sequential pages of the same scan; a single recipe may span multiple images, or each image may contain one or more distinct recipes."
    else
      "Extract all data from this image"
    end
    Rails.logger.debug "Sending #{image_blocks.length} image(s) to OpenAI API (model #{model})"

    response = @client.responses.create(
      parameters: {
        model: model,
        input: [
          {
            role: "system",
            content: system_prompt
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text: prompt_text
              },
              *image_blocks
            ]
          }
        ],
        reasoning: {
          "summary": "auto"
        },
        # store: true,
        # include: [
          # "reasoning.encrypted_content",
          # "web_search_call.action.sources"
        # ]
      }
    )

    Rails.logger.debug "OpenAI OCR response: #{response}"

    extract_recipes_from_response(response, "OpenAI OCR")
  end

  def parse_markdown_to_recipes(markdown_text)
    model = Rails.configuration.openai.recipe_markdown_model
    system_prompt = File.read(Rails.root.join("config", "prompts", Rails.configuration.openai.recipe_markdown_prompt_file))
    Rails.logger.debug "Sending markdown to OpenAI API (model #{model})"

    response = @client.responses.create(
      parameters: {
        model: model,
        input: [
          {
            role: "system",
            content: system_prompt
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text: markdown_text
              }
            ]
          }
        ],
        reasoning: {
          "summary": "auto"
        }
      }
    )

    Rails.logger.debug "OpenAI markdown parsing response: #{response}"

    output = response.dig("output") || []
    message = output.find { |item| item["type"] == "message" }
    llm_response_text = message&.dig("content", 0, "text")

    begin
      parsed = JSON.parse(llm_response_text)
      recipes = parsed['recipes'] || []
      Rails.logger.warn "No recipes found in OpenAI markdown parsing response" if recipes.empty?
      Rails.logger.info "OpenAI parsed #{recipes.length} recipes from markdown"
      recipes
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI markdown response: #{e.message}"
      raise
    rescue => e
      Rails.logger.error "Unexpected error parsing recipes from markdown: #{e.message}"
      raise
    end
  end

  def parse_url_to_recipes(markdown_text)
    model = Rails.configuration.openai.recipe_url_model
    system_prompt = File.read(Rails.root.join("config", "prompts", Rails.configuration.openai.recipe_url_prompt_file))
    Rails.logger.debug "Sending URL markdown to OpenAI API (model #{model})"

    response = @client.responses.create(
      parameters: {
        model: model,
        input: [
          {
            role: "system",
            content: system_prompt
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text: markdown_text
              }
            ]
          }
        ],
        reasoning: {
          "summary": "auto"
        }
      }
    )

    Rails.logger.debug "OpenAI URL parsing response: #{response}"

    output = response.dig("output") || []
    message = output.find { |item| item["type"] == "message" }
    llm_response_text = message&.dig("content", 0, "text")

    begin
      parsed = JSON.parse(llm_response_text)
      recipes = parsed['recipes'] || []
      Rails.logger.warn "No recipes found in OpenAI URL parsing response" if recipes.empty?
      Rails.logger.info "OpenAI parsed #{recipes.length} recipes from URL markdown"
      recipes
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI URL response: #{e.message}"
      raise
    rescue => e
      Rails.logger.error "Unexpected error parsing recipes from URL: #{e.message}"
      raise
    end
  end

  private

  def build_image_content_block(image_file, content_type)
    # Read and encode the image file as base64
    image_data = if image_file.respond_to?(:read)
      # Handle uploaded file (Tempfile)
      Base64.strict_encode64(image_file.read)
    elsif image_file.is_a?(String)
      # Handle file path
      File.open(image_file, 'rb') { |f| Base64.strict_encode64(f.read) }
    else
      raise ArgumentError, "Invalid image_file type"
    end

    # Determine the image format from content_type or file extension
    image_format = case content_type
      when /jpeg|jpg/ then 'jpeg'
      when /png/ then 'png'
      when /webp/ then 'webp'
      when /heic|heif/ then 'heic'
      else 'jpeg' # default
    end

    filedata = "data:image/#{image_format};base64,#{image_data}"

    {
      type: "input_image",
      image_url: filedata
    }
  end

  def extract_recipes_from_response(response, log_label)
    output = response.dig("output") || []
    message = output.find { |item| item["type"] == "message" }
    llm_response_text = message&.dig("content", 0, "text")

    begin
      parsed = JSON.parse(llm_response_text)
      recipes = parsed['recipes'] || []
      Rails.logger.warn "No recipes found in #{log_label} response" if recipes.empty?
      Rails.logger.info "#{log_label} recipes: #{recipes}"
      recipes
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse #{log_label} response: #{e.message}"
      []
    rescue => e
      Rails.logger.error "Unexpected error parsing recipes: #{e.message}"
      []
    end
  end
end
