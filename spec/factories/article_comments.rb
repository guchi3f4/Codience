FactoryBot.define do
  factory :article_comment do
    comment { Faker::Lorem.characters(number:20) }
    article
    user
  end
end