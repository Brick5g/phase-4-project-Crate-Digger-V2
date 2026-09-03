require "rails_helper"

RSpec.describe RecordGenre, type: :model do
  describe "validations" do
    it "is valid with a record and genre" do
      record_genre = build(:record_genre)

      expect(record_genre).to be_valid
    end

    it "allows notes to be blank" do
      record_genre = build(
        :record_genre,
        notes: nil
      )

      expect(record_genre).to be_valid
    end

    it "does not allow the same genre twice on one record" do
      record = create(:record)
      genre = create(:genre)

      create(
        :record_genre,
        record: record,
        genre: genre
      )

      duplicate = build(
        :record_genre,
        record: record,
        genre: genre
      )

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a record" do
      record_genre = create(:record_genre)

      expect(record_genre.record).to be_a(Record)
    end

    it "belongs to a genre" do
      record_genre = create(:record_genre)

      expect(record_genre.genre).to be_a(Genre)
    end
  end
end
