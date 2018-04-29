require 'rails_helper'

RSpec.describe Recipe, type: :model do
  context 'with new recipe' do
    it 'should save the recipe' do
      rc = Recipe.new do |r|
        r.name = 'marmorkuchen'
        r.ingredients =  'mehl,wasser,sonstiges'
        r.instructions = 'zusammenschuetten und backen'
      end
      rc.save
      expect(Recipe.count).to eq 1
    end
    it 'should not save the recipe without name' do
      rc = Recipe.new do |r|
        r.ingredients =  'mehl,wasser,sonstiges'
        r.instructions = 'zusammenschuetten und backen'
      end
      rc.save
      expect(Recipe.count).to eq 0
    end
    it 'should save comma separted tags' do
      rc = Recipe.new do |r|
        r.name = 'rezept mit tags'
        r.ingredients = 'mehl,wasser,sonstiges'
        r.instructions = 'zusammenschuetten und backen'
        r.tag_names = 'mehl, Wasser,ei'
      end
      rc.save
      expect(Recipe.count).to eq 1
      expect(Tag.count).to eq 3
    end
  end
  context 'existing recipe' do
    it 'should list its tags as csv list' do
      create(:recipe)
      expect(Recipe.where(name: 'Wurstbrot').first.tag_names).to eq('Brot, Wurst')
    end
  end
  context 'existing recipes' do
    it 'should be sorted alphabetically case-insensitive' do
      r1 = create(:recipe, :name => 'zAaa')
      create(:recipe, :name => 'aAab', :tags => r1.tags)
      create(:recipe, :name => 'AAaa', :tags => r1.tags)
      expect(Recipe.count).to eq 3
      r = Recipe.order_by_name
      expect(r[0].name).to eq 'AAaa'
      expect(r[1].name).to eq 'aAab'
      expect(r[2].name).to eq 'zAaa'
    end
  end
end
