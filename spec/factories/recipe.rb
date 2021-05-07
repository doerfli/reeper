FactoryBot.define do
  factory :recipe do
    name { 'Wurstbrot' }
    ingredients { '1 Brot\n3 Scheiben Wurst'}
    instructions {'- Brot schneiden\n-Wurst drauf legen\n'}
    duration {1}
    source {'Allgemeinwissen'}
    favorite {false}

    after(:create) do |r, evaluator|
      unless r.tags.count > 0
        r.tags << create(:brot)
        r.tags << create(:wurst)
      end
    end
  end
end