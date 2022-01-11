class Recipe < ApplicationRecord
  has_and_belongs_to_many :tags
  has_many_attached :recipe_images
  has_rich_text :instructions 
  has_rich_text :ingredients

  validates :name, presence: true

  after_save :update_tags_count
  before_destroy :update_tags_count

  paginates_per 15

  scope :order_by_name, -> { order(Recipe.arel_table[:name].lower, :id) }

  def tag_names
    # Get all related Tags as comma-separated list
    tag_list = []
    tags.each do |tag|
      tag_list << tag.name
    end
    tag_list.join(', ')
  end

  def tag_names=(names)
    logger.info names
    # Delete tag-relations
    self.tags.clear

    # Split comma-separated list
    names = names.split(',').map{ |n| n.strip }.select{ |n| ! n.empty? }

    # Run through each tag
    names.each do |name|
      tag = Tag.find_or_create_by(name: name)
      logger.info tag
      self.tags << tag
    end
  end

  def add_images=(images)
    images.each do |image|
      self.recipe_images.attach(image)
    end
  end

  def update_tags_count
    tags.each do |tag| 
      tag.recipes_count = tag.recipes.count
      tag.save
    end
  end
  
end
