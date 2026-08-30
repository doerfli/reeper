module RecipeJsonParser
  def parse_recipes_json(text, log_label, on_error: :empty)
    parsed = JSON.parse(text)
    recipes = parsed['recipes'] || []
    Rails.logger.warn "No recipes found in #{log_label} response" if recipes.empty?
    Rails.logger.info "#{log_label} recipes: #{recipes}"
    recipes
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse #{log_label} response: #{e.message}"
    raise if on_error == :raise
    []
  rescue => e
    Rails.logger.error "Unexpected error parsing recipes from #{log_label}: #{e.message}"
    raise if on_error == :raise
    []
  end

  # Parses the { "index": <n|null> } answer of the main-image selection prompt.
  # Returns an Integer or nil - nil means "none of the candidates is the dish".
  def parse_image_index_json(text, log_label)
    index = JSON.parse(text.to_s)['index']
    Rails.logger.info "#{log_label} selected image index: #{index.inspect}"
    index.is_a?(Integer) ? index : nil
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse #{log_label} response: #{e.message}"
    nil
  end
end
