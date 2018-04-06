class DeleteEmptyTags < ActiveRecord::Migration[5.2]
  def up
    empty_tag = Tag.where(name: "")
    return if empty_tag.nil?
    puts ','

    recipies = Recipe.joins(:tags).where(tags: { id: empty_tag})
    recipies.each{ |r|
      r.tags.delete(empty_tag)
      puts '-'
    }

    empty_tag.each{ |t| t.delete }
    puts "."
  end
end
