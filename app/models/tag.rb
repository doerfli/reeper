class Tag < ApplicationRecord
  has_and_belongs_to_many :recipes

  validates :name, uniqueness: true

  # tags with at least one recipe
  default_scope lambda {
    joins(:recipes)
      .group('id').having('COUNT(recipes.id) > 0')
  }

  # tags with at least one recipe matching the term
  scope :match_term, lambda { |term|
    name_q = Tag.arel_table[:name]
    joins(:recipes)
      .where(name_q.matches("%#{term.downcase}%"))
      .group('id').having('COUNT(recipes.id) > 0')
  }

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
