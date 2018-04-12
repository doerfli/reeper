class Tag < ApplicationRecord
  has_and_belongs_to_many :recipes

  scope :match_term, ->(term) { where('name ILIKE ?', "%#{term.downcase}%") }
end
