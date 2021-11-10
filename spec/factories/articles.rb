FactoryBot.define do
  factory :article do
    title { Faker::Lorem.characters(number:10) }
    link { Faker::Internet.url }
    summary { Faker::Lorem.characters(number:20) }
    body { Faker::Lorem.characters(number:30) }
    user
    category
  end
end