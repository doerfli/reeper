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

    # puts "Image format detected: #{image_format} for content type: #{content_type} content #{image_data[0..30]}..."
    filedata = "data:image/#{image_format};base64,#{image_data}"

    response = @client.ocr(filedata, kind: :image)
    recognized_markdown = response.pages[0].markdown

    Rails.logger.debug "Mistral OCR result:\n#{recognized_markdown[0..100]}..."
    recognized_markdown
  end
end
