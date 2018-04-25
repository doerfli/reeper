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
  end
end
