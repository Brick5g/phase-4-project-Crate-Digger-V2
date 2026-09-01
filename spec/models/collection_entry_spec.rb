require "rails_helper"

RSpec.describe CollectionEntry, type: :model do
  describe "validations" do
    it "is valid with a purchase price, notes, user, and record" do
      collection_entry = build(:collection_entry)

      expect(collection_entry).to be_valid
    end

    it "is invalid without a purchase price" do
      collection_entry = build(:collection_entry, purchase_price: nil)

      expect(collection_entry).not_to be_valid
    end

    it "is invalid without notes" do
      collection_entry = build(:collection_entry, notes: nil)

      expect(collection_entry).not_to be_valid
    end

    it "does not allow the same record twice for the same user" do
      user = create(:user)
      record = create(:record)

      create(:collection_entry, user: user, record: record)

      duplicate_entry = build(:collection_entry, user: user, record: record)

      expect(duplicate_entry).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a user" do
      collection_entry = create(:collection_entry)

      expect(collection_entry.user).to be_a(User)
    end

    it "belongs to a record" do
      collection_entry = create(:collection_entry)

      expect(collection_entry.record).to be_a(Record)
    end
  end
end
