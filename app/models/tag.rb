class Tag < ApplicationRecord
  has_and_belongs_to_many :recipes

  validates :name, uniqueness: true

  scope :match_term, ->(term) { where('name ILIKE ?', "%#{term.downcase}%") }

  def self.sort_by_recipe_count(tags)
    tags.sort do |a, b|
      sa = a.recipe_count
      sb = b.recipe_count
      sb <=> sa
    end
  end

  def recipe_count
    recipes.size
  end
end
