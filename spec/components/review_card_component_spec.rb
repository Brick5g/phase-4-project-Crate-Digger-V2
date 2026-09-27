# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewCardComponent, type: :component do
  let(:user) do
    create(
      :user
    )
  end

  let(:review) do
    create(
      :review,
      user: user,
      rating: 9,
      body: "Great release."
    )
  end

  it "renders review information" do
    render_inline(
      described_class.new(
        review: review,
        current_user: nil
      )
    )

    expect(page).to have_content(
      user.username
    )

    expect(page).to have_content(
      "9 / 10"
    )

    expect(page).to have_content(
      "Great release."
    )
  end

  it "shows the edit link to the review owner" do
    render_inline(
      described_class.new(
        review: review,
        current_user: user
      )
    )

    expect(page).to have_link(
      "Edit My Review"
    )
  end

  it "does not show the edit link to another user" do
    other_user = create(
      :user
    )

    render_inline(
      described_class.new(
        review: review,
        current_user: other_user
      )
    )

    expect(page).not_to have_link(
      "Edit My Review"
    )
  end

  it "does not render an empty review body" do
    review.update!(
      body: nil
    )

    render_inline(
      described_class.new(
        review: review,
        current_user: user
      )
    )

    expect(page).not_to have_css(
      ".review-card p"
    )
  end
end
