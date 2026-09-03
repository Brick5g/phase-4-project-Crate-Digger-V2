require "rails_helper"

RSpec.describe RecordGenre, type: :model do
  describe "primary genre validation" do
    it "allows one primary genre for a release" do
      record = create(:record)
      genre = create(:genre)

      record_genre = build(
        :record_genre,
        record: record,
        genre: genre,
        primary_genre: true
      )

      expect(record_genre).to be_valid
    end

    it "does not allow two primary genres for the same release" do
      record = create(:record)

      first_genre = create(:genre)
      second_genre = create(:genre)

      create(
        :record_genre,
        record: record,
        genre: first_genre,
        primary_genre: true
      )

      second_primary = build(
        :record_genre,
        record: record,
        genre: second_genre,
        primary_genre: true
      )

      expect(second_primary).not_to be_valid

      expect(
        second_primary.errors[:primary_genre]
      ).to include(
        "has already been selected for this release"
      )
    end

    it "allows multiple non-primary genres for the same release" do
      record = create(:record)

      first_genre = create(:genre)
      second_genre = create(:genre)

      create(
        :record_genre,
        record: record,
        genre: first_genre,
        primary_genre: false
      )

      second_genre_relationship = build(
        :record_genre,
        record: record,
        genre: second_genre,
        primary_genre: false
      )

      expect(second_genre_relationship).to be_valid
    end
  end
end
