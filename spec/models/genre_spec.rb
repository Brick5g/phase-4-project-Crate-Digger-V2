require "rails_helper"

RSpec.describe Genre, type: :model do
  describe "validations" do
    it "is valid with a name" do
      genre = build(:genre)

      expect(genre).to be_valid
    end

    it "is invalid without a name" do
      genre = build(:genre, name: nil)

      expect(genre).not_to be_valid
      expect(genre.errors[:name]).to include("can't be blank")
    end

    it "allows a genre without a description" do
      genre = build(:genre, description: nil)

      expect(genre).to be_valid
    end

    it "does not allow duplicate genre names" do
      create(:genre, name: "Hip-Hop")

      duplicate = build(
        :genre,
        name: "Hip-Hop"
      )

      expect(duplicate).not_to be_valid
    end

    it "does not allow duplicate genre names with different capitalization" do
      create(:genre, name: "Hip-Hop")

      duplicate = build(
        :genre,
        name: "hip-hop"
      )

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "has many records through record genres" do
      genre = create(:genre)
      record = create(:record)

      create(
        :record_genre,
        record: record,
        genre: genre
      )

      expect(genre.records).to include(record)
    end

    it "has many artists through artist genres" do
      genre = create(:genre)
      artist = create(:artist)

      ArtistGenre.create!(
        artist: artist,
        genre: genre,
        primary_genre: true
      )

      expect(genre.artists).to include(artist)
    end
  end
end
