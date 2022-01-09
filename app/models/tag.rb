class Tag < ApplicationRecord
  has_and_belongs_to_many :recipes

  validates :name, uniqueness: true, presence: true

  # tags with at least one recipe
  scope :with_recipes, lambda {
    where("recipes_count > 0").order("recipes_count DESC")
  }

  # tags with at least one recipe matching the term
  scope :match_term, lambda { |term|
    where("recipes_count > 0 AND lower(name) LIKE ?", "%#{sanitize_sql_like(term).downcase}%")
  }

  def recipe_count
    recipes.size
  end
end
