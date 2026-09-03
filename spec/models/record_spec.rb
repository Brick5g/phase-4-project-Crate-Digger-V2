require "rails_helper"

RSpec.describe Record, type: :model do
  describe "relationships" do
    it "belongs to an artist" do
      record = create(:record)

      expect(record.artist).to be_present
    end

    it "can have many genres through record genres" do
      record = create(:record)
      genre = create(:genre)

      create(
        :record_genre,
        record: record,
        genre: genre
      )

      expect(record.genres).to include(genre)
    end

    it "can belong to many users through collection entries" do
      record = create(:record)
      user = create(:user)

      create(
        :collection_entry,
        record: record,
        user: user
      )

      expect(record.users).to include(user)
    end

    it "can have many reviews" do
      record = create(:record)
      review = create(
        :review,
        record: record
      )

      expect(record.reviews).to include(review)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      record = build(:record)

      expect(record).to be_valid
    end

    it "is invalid without a title" do
      record = build(:record, title: nil)

      expect(record).not_to be_valid
    end

    it "is invalid without a release type" do
      record = build(:record, release_type: nil)

      expect(record).not_to be_valid
    end

    it "allows a missing release date" do
      record = build(:record, release_date: nil)

      expect(record).to be_valid
    end

    it "allows a missing MusicBrainz ID" do
      record = build(:record, musicbrainz_id: nil)

      expect(record).to be_valid
    end

    it "does not allow duplicate MusicBrainz IDs" do
      create(
        :record,
        musicbrainz_id: "12345"
      )

      duplicate_record = build(
        :record,
        musicbrainz_id: "12345"
      )

      expect(duplicate_record).not_to be_valid
    end
  end

  describe ".alphabetical" do
    it "returns records ordered alphabetically by title" do
      create(:record, title: "Zebra")
      create(:record, title: "Abbey Road")
      create(:record, title: "Midnight Marauders")

      titles = Record.alphabetical.pluck(:title)

      expect(titles).to eq(
        [
          "Abbey Road",
          "Midnight Marauders",
          "Zebra"
        ]
      )
    end
  end
end
