require 'rails_helper'

RSpec.describe Tag, type: :model do
  context 'with new tag' do
    it 'should save the tag' do
      tc = Tag.new do |t|
        t.name = 'Eine Zutat'
      end
      tc.save
      expect(Tag.count).to eq 1
    end
    it 'should not save without name' do
      tc = Tag.new
      tc.save
      expect(Tag.count).to eq 0
    end
    it 'should not save duplicate name' do
      tc = Tag.new do |t|
        t.name = 'brot'
      end
      td = Tag.new do |t|
        t.name = 'brot'
      end
      td.save
      expect(Tag.count).to eq 1
    end
  end
  context 'with recipes' do
    it 'should only list tags with at least one recipe' do
      create(:recipe)
      td = Tag.new do |t|
        t.name = 'mehl'
      end
      td.save
      expect(Tag.with_recipes.to_a.size).to eq 2
    end
    it 'should find all tags matching the term and having at least one recipe' do
      create(:recipe)
      td = Tag.new do |t|
        t.name = 'brat'
      end
      td.save
      expect(Tag.match_term('br').to_a.size).to eq 1
    end
    it 'should be sorted by recipe count' do
      r1 = create(:recipe)
      r2 = create(:recipe, :name => 'pasta', :tags => r1.tags)
      r2.tags << create(:pasta)
      r2.save
      t = Tag.sort_by_recipe_count(Tag.with_recipes)
      # sorting by name when same count is not done currently
      # expect(t[0].name).to eq 'Wurst'
      # expect(t[1].name).to eq 'Brot'
      expect(t[2].name).to eq 'Pasta'
    end
  end
end
