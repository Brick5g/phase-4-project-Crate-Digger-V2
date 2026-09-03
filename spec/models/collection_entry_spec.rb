require "rails_helper"

RSpec.describe CollectionEntry, type: :model do
  it "is valid with valid attributes" do
    collection_entry = build(:collection_entry)

    expect(collection_entry).to be_valid
  end

  it "requires notes" do
    collection_entry = build(
      :collection_entry,
      notes: ""
    )

    expect(collection_entry).not_to be_valid
  end

  it "does not allow the same record twice in one user's collection" do
    user = create(:user)
    record = create(:record)

    create(
      :collection_entry,
      user: user,
      record: record
    )

    duplicate_entry = build(
      :collection_entry,
      user: user,
      record: record
    )

    expect(duplicate_entry).not_to be_valid
  end

  it "allows different users to save the same record" do
    record = create(:record)
    first_user = create(:user)
    second_user = create(:user)

    create(
      :collection_entry,
      user: first_user,
      record: record
    )

    second_entry = build(
      :collection_entry,
      user: second_user,
      record: record
    )

    expect(second_entry).to be_valid
  end
end
