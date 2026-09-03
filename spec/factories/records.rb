FactoryBot.define do
  factory :record do
    association :artist

    sequence(:title) { |number| "Record #{number}" }

    release_date { Date.new(1993, 11, 9) }
    release_type { "Album" }

    artwork_url { nil }
    musicbrainz_id { nil }

    description { "A music release." }
  end
end
