FactoryBot.define do
  factory :user do
    username { "crate_digger" }
    sequence(:email) { |n| "collector#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
