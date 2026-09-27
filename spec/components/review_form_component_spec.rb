# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewFormComponent, type: :component do
  let(:record) do
    create(
      :record
    )
  end

  it "renders a new review form" do
    review = build(
      :review,
      record: record
    )

    render_inline(
      described_class.new(
        review: review,
        record: record
      )
    )

    expect(page).to have_content(
      "Your Rating"
    )

    expect(page).to have_field(
      "review_rating_1"
    )

    expect(page).to have_field(
      "review_rating_10"
    )

    expect(page).to have_field(
      "Your Thoughts (Optional)"
    )

    expect(page).to have_button(
      "Save My Review"
    )
  end

  it "renders an edit review form" do
    review = create(
      :review,
      record: record
    )

    render_inline(
      described_class.new(
        review: review,
        record: record
      )
    )

    expect(page).to have_button(
      "Update My Review"
    )

    expect(page).not_to have_button(
      "Save My Review"
    )
  end

  it "renders the existing rating when editing" do
    review = create(
      :review,
      record: record,
      rating: 8
    )

    render_inline(
      described_class.new(
        review: review,
        record: record
      )
    )

    expect(page).to have_checked_field(
      "review_rating_8"
    )
  end

  it "renders validation errors" do
    review = build(
      :review,
      record: record,
      rating: nil
    )

    review.valid?

    render_inline(
      described_class.new(
        review: review,
        record: record
      )
    )

    expect(page).to have_css(
      ".validation-errors"
    )
  end
end
