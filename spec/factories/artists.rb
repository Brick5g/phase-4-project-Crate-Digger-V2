FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Artist #{n}" }
    country { "United States" }
  end
end
