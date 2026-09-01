require "rails_helper"

RSpec.describe Genre, type: :model do
  describe "validations" do
    it "is valid with a name and description" do
      genre = build(:genre)

      expect(genre).to be_valid
    end

    it "is invalid without a name" do
      genre = build(:genre, name: nil)

      expect(genre).not_to be_valid
    end

    it "is invalid without a description" do
      genre = build(:genre, description: nil)

      expect(genre).not_to be_valid
    end

    it "does not allow duplicate names" do
      create(:genre, name: "Hip-Hop")
      duplicate_genre = build(:genre, name: "Hip-Hop")

      expect(duplicate_genre).not_to be_valid
    end
  end
end
