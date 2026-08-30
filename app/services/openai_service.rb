class OpenaiService
  include ImageDataUri
  include RecipeJsonParser

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

  def ocr_multi(image_files_with_types)
    image_blocks = image_files_with_types.map { |image_file, content_type| build_image_content_block(image_file, content_type) }

    model = Rails.configuration.openai.recipe_ocr_model
    system_prompt = File.read(Rails.root.join("config", "prompts", Rails.configuration.openai.recipe_ocr_prompt_file))
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
                text: "Extract all data from the following image(s)"
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

    parse_recipes_json(extract_message_text(response), "OpenAI markdown parsing", on_error: :raise)
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

    parse_recipes_json(extract_message_text(response), "OpenAI URL parsing", on_error: :raise)
  end

  # candidates is an array of { url:, alt: } hashes. Returns the index of the
  # image showing the finished dish, or nil when none of them qualifies.
  def select_main_image(candidates)
    model = Rails.configuration.openai.image_select_model
    system_prompt = File.read(Rails.root.join("config", "prompts", Rails.configuration.openai.image_select_prompt_file))
    Rails.logger.debug "Sending #{candidates.length} image candidate(s) to OpenAI API (model #{model})"

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
                text: image_candidates_payload(candidates)
              }
            ]
          }
        ]
      }
    )

    Rails.logger.debug "OpenAI image selection response: #{response}"

    parse_image_index_json(extract_message_text(response), "OpenAI image selection")
  end

  private

  def image_candidates_payload(candidates)
    candidates.each_with_index.map { |candidate, index|
      { index: index, url: candidate[:url], alt: candidate[:alt] }
    }.to_json
  end

  def build_image_content_block(image_file, content_type)
    {
      type: "input_image",
      image_url: build_data_uri(image_file, content_type)
    }
  end

  def extract_message_text(response)
    output = response.dig("output") || []
    message = output.find { |item| item["type"] == "message" }
    message&.dig("content", 0, "text")
  end

  def extract_recipes_from_response(response, log_label)
    parse_recipes_json(extract_message_text(response), log_label)
  end
end
