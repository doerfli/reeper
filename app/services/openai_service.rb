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

    # puts "Image format detected: #{image_format} for content type: #{content_type} content #{image_data[0..30]}..."
    filedata = "data:image/#{image_format};base64,#{image_data}"
    prompt_id = Rails.configuration.openai.recipe_ocr_prompt_id
    prompt_version = Rails.configuration.openai.recipe_ocr_prompt_version
    Rails.logger.debug "Sending data to OpenAI API (Prompt id #{prompt_id} version #{prompt_version} -> #{filedata[0..100]}..."

    response = @client.responses.create(
      parameters: {
        # model: "gpt-5-nano",
        prompt: {
          "id": prompt_id,
          "version": prompt_version
        },
        input: [
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text: "Extract all data from this image"
              },
              {
                type: "input_image",
                image_url: filedata
              }
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

    output = response.dig("output") || []
    message = output.find { |item| item["type"] == "message" }
    llm_response_text = message&.dig("content", 0, "text")

    begin
      parsed = JSON.parse(llm_response_text)
      recipes = parsed['recipes'] || []
      Rails.logger.warn "No recipes found in OpenAI response" if recipes.empty?
      Rails.logger.info "OpenAI OCR recipes: #{recipes}"
      recipes
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI response: #{e.message}"
      []
    rescue => e
      Rails.logger.error "Unexpected error parsing recipes: #{e.message}"
      []
    end
  end

  def parse_markdown_to_recipes(markdown_text)
    prompt_id = Rails.configuration.openai.recipe_markdown_prompt_id
    prompt_version = Rails.configuration.openai.recipe_markdown_prompt_version
    Rails.logger.debug "Sending markdown to OpenAI API (Prompt id #{prompt_id} version #{prompt_version})"

    response = @client.responses.create(
      parameters: {
        prompt: {
          "id": prompt_id,
          "version": prompt_version
        },
        input: [
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
end
