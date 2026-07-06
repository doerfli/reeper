module ImageDataUri
  def build_data_uri(image_file, content_type)
    image_data = if image_file.respond_to?(:read)
      image_file.rewind if image_file.respond_to?(:rewind)
      data = Base64.strict_encode64(image_file.read)
      image_file.rewind if image_file.respond_to?(:rewind)
      data
    elsif image_file.is_a?(String)
      File.open(image_file, 'rb') { |f| Base64.strict_encode64(f.read) }
    else
      raise ArgumentError, "Invalid image_file type"
    end

    image_format = case content_type
      when /jpeg|jpg/ then 'jpeg'
      when /png/ then 'png'
      when /webp/ then 'webp'
      when /heic|heif/ then 'heic'
      else 'jpeg' # default
    end

    "data:image/#{image_format};base64,#{image_data}"
  end
end
