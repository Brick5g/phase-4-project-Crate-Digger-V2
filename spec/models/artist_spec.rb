require "rails_helper"

RSpec.describe Artist, type: :model do
  describe "validations" do
    it "is valid with a name and country" do
      artist = build(:artist)

      expect(artist).to be_valid
    end

    it "is invalid without a name" do
      artist = build(:artist, name: nil)

      expect(artist).not_to be_valid
    end

    it "is invalid without a country" do
      artist = build(:artist, country: nil)

      expect(artist).not_to be_valid
    end

    it "does not allow duplicate names" do
      create(:artist, name: "OutKast")
      duplicate_artist = build(:artist, name: "OutKast")

      expect(duplicate_artist).not_to be_valid
    end
  end
end
