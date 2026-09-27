# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectionCardComponent, type: :component do
  let(:user) do
    create(
      :user
    )
  end

  let(:entry) do
    create(
      :collection_entry,
      user: user
    )
  end

  it "renders the release information" do
    render_inline(
      described_class.new(
        entry: entry,
        review: nil
      )
    )

    expect(page).to have_content(
      entry.record.title
    )

    expect(page).to have_content(
      entry.record.artist.name
    )

    expect(page).to have_link(
      "View Release"
    )
  end

  it "renders the user's rating when reviewed" do
    review = create(
      :review,
      user: user,
      record: entry.record,
      rating: 9
    )

    render_inline(
      described_class.new(
        entry: entry,
        review: review
      )
    )

    expect(page).to have_content(
      "9 / 10"
    )

    expect(page).not_to have_link(
      "Rate This Release"
    )
  end

  it "offers a rating link when not reviewed" do
    render_inline(
      described_class.new(
        entry: entry,
        review: nil
      )
    )

    expect(page).to have_content(
      "You have not rated this release yet."
    )

    expect(page).to have_link(
      "Rate This Release"
    )
  end

  it "renders collection notes when present" do
    entry.update!(
      notes: "One of my favorites."
    )

    render_inline(
      described_class.new(
        entry: entry,
        review: nil
      )
    )

    expect(page).to have_content(
      "One of my favorites."
    )
  end

  it "renders the missing artwork state" do
    entry.record.update!(
      artwork_url: nil
    )

    render_inline(
      described_class.new(
        entry: entry,
        review: nil
      )
    )

    expect(page).to have_content(
      "No Artwork"
    )
  end
end
