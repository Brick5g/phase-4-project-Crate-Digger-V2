FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "Genre #{n}" }
    description { "A genre used for testing." }
  end
end
