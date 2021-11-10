FactoryBot.define do
  factory :category do
    name { Faker::Lorem.characters(number:8) }
  end
end