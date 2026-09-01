require "rails_helper"

RSpec.describe Record, type: :model do
  describe "validations" do
    it "is valid with a title, release year, format, condition, and artist" do
      record = build(:record)

      expect(record).to be_valid
    end

    it "is invalid without a title" do
      record = build(:record, title: nil)

      expect(record).not_to be_valid
    end

    it "is invalid without a release year" do
      record = build(:record, release_year: nil)

      expect(record).not_to be_valid
    end

    it "is invalid without a format" do
      record = build(:record, format: nil)

      expect(record).not_to be_valid
    end

    it "is invalid without a condition" do
      record = build(:record, condition: nil)

      expect(record).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to an artist" do
      record = create(:record)

      expect(record.artist).to be_a(Artist)
    end
  end

  describe "scopes" do
    it "returns records in alphabetical order by title" do
      create(:record, title: "Zebra")
      create(:record, title: "Abbey Road")
      create(:record, title: "Midnight Marauders")

      expect(Record.alphabetical.pluck(:title)).to eq(
        [ "Abbey Road", "Midnight Marauders", "Zebra" ]
      )
    end
  end
end
