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
end
