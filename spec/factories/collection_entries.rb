FactoryBot.define do
  factory :collection_entry do
    purchase_price { 25.00 }
    notes { "Added for testing." }

    association :user
    association :record
  end
end
