require "rails_helper"

RSpec.describe Review, type: :model do
  it "is valid with valid attributes" do
    review = build(:review)

    expect(review).to be_valid
  end

  it "requires a rating" do
    review = build(:review, rating: nil)

    expect(review).not_to be_valid
  end

  it "requires a rating between 1 and 10" do
    low_review = build(:review, rating: 0)
    high_review = build(:review, rating: 11)

    expect(low_review).not_to be_valid
    expect(high_review).not_to be_valid
  end

  it "allows the review text to be blank" do
    review = build(
      :review,
      rating: 8,
      body: ""
    )

    expect(review).to be_valid
  end

  it "allows a user to review a record only once" do
    user = create(:user)
    record = create(:record)

    create(
      :review,
      user: user,
      record: record
    )

    duplicate_review = build(
      :review,
      user: user,
      record: record
    )

    expect(duplicate_review).not_to be_valid
  end

  it "allows different users to review the same record" do
    record = create(:record)
    first_user = create(:user)
    second_user = create(:user)

    create(
      :review,
      user: first_user,
      record: record
    )

    second_review = build(
      :review,
      user: second_user,
      record: record
    )

    expect(second_review).to be_valid
  end
end
