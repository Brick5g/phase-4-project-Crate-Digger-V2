FactoryBot.define do
  factory :review do
    association :user
    association :record

    rating { 8 }
    body { "Great record with a lot of replay value." }
  end
end
