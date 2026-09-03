require "rails_helper"

RSpec.describe ArtistGenre, type: :model do
  describe "associations" do
    it "belongs to an artist" do
      artist_genre = ArtistGenre.new

      expect(artist_genre).to respond_to(:artist)
    end

    it "belongs to a genre" do
      artist_genre = ArtistGenre.new

      expect(artist_genre).to respond_to(:genre)
    end
  end

  describe "validations" do
    it "allows one primary genre for an artist" do
      artist = create(:artist)
      genre = create(:genre)

      artist_genre = ArtistGenre.new(
        artist: artist,
        genre: genre,
        primary_genre: true
      )

      expect(artist_genre).to be_valid
    end

    it "does not allow the same genre twice for one artist" do
      artist = create(:artist)
      genre = create(:genre)

      ArtistGenre.create!(
        artist: artist,
        genre: genre,
        primary_genre: true
      )

      duplicate = ArtistGenre.new(
        artist: artist,
        genre: genre,
        primary_genre: false
      )

      expect(duplicate).not_to be_valid
    end

    it "does not allow two primary genres for the same artist" do
      artist = create(:artist)

      hip_hop = create(:genre, name: "Hip-Hop")
      r_and_b = create(:genre, name: "R&B")

      ArtistGenre.create!(
        artist: artist,
        genre: hip_hop,
        primary_genre: true
      )

      second_primary = ArtistGenre.new(
        artist: artist,
        genre: r_and_b,
        primary_genre: true
      )

      expect(second_primary).not_to be_valid

      expect(
        second_primary.errors[:primary_genre]
      ).to include(
        "has already been selected for this artist"
      )
    end

    it "allows unlimited additional genres" do
      artist = create(:artist)

      hip_hop = create(:genre, name: "Hip-Hop")
      r_and_b = create(:genre, name: "R&B")
      rap = create(:genre, name: "Rap")
      house = create(:genre, name: "House")

      ArtistGenre.create!(
        artist: artist,
        genre: hip_hop,
        primary_genre: true
      )

      [ r_and_b, rap, house ].each do |genre|
        ArtistGenre.create!(
          artist: artist,
          genre: genre,
          primary_genre: false
        )
      end

      expect(artist.genres.count).to eq(4)
    end
  end
end
