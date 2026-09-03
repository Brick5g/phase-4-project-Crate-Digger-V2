FactoryBot.define do
  factory :artist_genre do
    artist { nil }
    genre { nil }
    primary_genre { false }
  end
end
