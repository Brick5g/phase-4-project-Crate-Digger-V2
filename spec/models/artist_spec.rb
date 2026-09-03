require "rails_helper"

RSpec.describe Artist, type: :model do
  describe "validations" do
    it "is valid with valid information" do
      artist = build(:artist)

      expect(artist).to be_valid
    end

    it "is invalid without a name" do
      artist = build(:artist, name: nil)

      expect(artist).not_to be_valid
      expect(artist.errors[:name]).to include("can't be blank")
    end

    it "allows an artist without a country" do
      artist = build(:artist, country: nil)

      expect(artist).to be_valid
    end

    it "does not allow duplicate artist names" do
      create(:artist, name: "A Tribe Called Quest")

      duplicate = build(
        :artist,
        name: "A Tribe Called Quest"
      )

      expect(duplicate).not_to be_valid
    end

    it "does not allow duplicate MusicBrainz IDs" do
      create(
        :artist,
        musicbrainz_id: "artist-mbid-123"
      )

      duplicate = build(
        :artist,
        musicbrainz_id: "artist-mbid-123"
      )

      expect(duplicate).not_to be_valid
    end

    it "allows blank MusicBrainz IDs" do
      first_artist = create(
        :artist,
        musicbrainz_id: nil
      )

      second_artist = build(
        :artist,
        musicbrainz_id: nil
      )

      expect(first_artist).to be_valid
      expect(second_artist).to be_valid
    end
  end

  describe "associations" do
    it "has many records" do
      artist = create(:artist)
      record = create(:record, artist: artist)

      expect(artist.records).to include(record)
    end

    it "has many genres through artist genres" do
      artist = create(:artist)
      genre = create(:genre)

      ArtistGenre.create!(
        artist: artist,
        genre: genre,
        primary_genre: true
      )

      expect(artist.genres).to include(genre)
    end
  end
end
