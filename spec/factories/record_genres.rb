FactoryBot.define do
  factory :record_genre do
    primary_genre { false }
    notes { "Added for testing." }

    association :record
    association :genre
  end
end
