FactoryBot.define do
  factory :record do
    title { "Test Album" }
    release_year { 2020 }
    format { "Vinyl" }
    condition { "Near Mint" }

    association :artist
  end
end
