FactoryBot.define do
  factory :artist do
    sequence(:name) { |number| "Artist #{number}" }
    country { "United States" }
    hometown { "New York" }
    details { "Artist information." }
    musicbrainz_id { nil }
  end
end
