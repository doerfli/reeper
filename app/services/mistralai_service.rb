class MistralaiService
  def initialize
    # API key validation happens at runtime (not initialization) to allow
    # the service to be instantiated even when Mistral AI is not configured.
    # This is intentional - the key is only checked when the service is actually used.
    api_key = ENV['MISTRAL_API_KEY']
    raise "Mistral API key not configured. Set MISTRAL_API_KEY environment variable" if api_key.blank?

    @client = OmniAI::Mistral::Client.new
  end

  def ocr_to_markdown(image_file, content_type)
    # Read and encode the image file as base64
    image_data = if image_file.respond_to?(:read)
      # Handle uploaded file (Tempfile)
      image_file.rewind
      data = Base64.strict_encode64(image_file.read)
      image_file.rewind  # Reset for potential subsequent reads
      data
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

    Rails.logger.debug "Image format detected: #{image_format} for content type: #{content_type}"
    filedata = "data:image/#{image_format};base64,#{image_data}"

    response = @client.ocr(filedata, kind: :image)
    recognized_markdown = response.pages[0].markdown

    Rails.logger.debug "Mistral OCR result:\n#{recognized_markdown[0..100]}..."
    recognized_markdown
  end

  def parse_markdown_to_recipes(markdown_text)
    Rails.logger.debug "Sending markdown to Mistral AI API for parsing"

    # Load the system prompt from the file
    system_prompt_file_path = Rails.root.join("config", "prompts", "openai_markdown.txt")
    system_prompt = File.read(system_prompt_file_path)

    # Use the client.chat block syntax with system and user prompts
    completion = @client.chat(model: "mistral-small-latest") do |chat|
      chat.system(system_prompt)
      chat.user(markdown_text)
    end

    Rails.logger.debug "Mistral AI markdown parsing response: #{completion.text}"

    llm_response_text = completion.text.gsub(/```json/, '').gsub(/```/, '')

    begin
      parsed = JSON.parse(llm_response_text)
      recipes = parsed['recipes'] || []
      Rails.logger.warn "No recipes found in Mistral AI response" if recipes.empty?
      Rails.logger.info "Mistral AI parsed #{recipes.length} recipes from markdown"
      recipes
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse Mistral AI markdown response: #{e.message}"
      raise
    rescue => e
      Rails.logger.error "Unexpected error parsing recipes from markdown: #{e.message}"
      raise
    end
  end
end
