FactoryBot.define do
  factory :collection_entry do
    association :user
    association :record

    notes { "Saved to my collection." }
  end
end
