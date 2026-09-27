# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordCardComponent, type: :component do
  it "renders record information" do
    artist = create(
      :artist
    )

    record = create(
      :record,
      artist: artist,
      title: "Test Release",
      release_type: "Album",
      release_date: Date.new(2026, 1, 1)
    )

    render_inline(
      described_class.new(
        record: record
      )
    )

    expect(page).to have_link(
      "Test Release"
    )

    expect(page).to have_content(
      artist.name
    )

    expect(page).to have_content(
      "Album"
    )

    expect(page).to have_content(
      "2026-01-01"
    )
  end

  it "shows Unknown when the release date is missing" do
    record = create(
      :record,
      release_date: nil
    )

    render_inline(
      described_class.new(
        record: record
      )
    )

    expect(page).to have_content(
      "Release Date:"
    )

    expect(page).to have_content(
      "Unknown"
    )
  end

  it "renders artwork when artwork is available" do
    record = create(
      :record,
      artwork_url: "https://example.com/cover.jpg"
    )

    render_inline(
      described_class.new(
        record: record
      )
    )

    expect(page).to have_css(
      "img[src='https://example.com/cover.jpg']"
    )
  end

  it "does not render artwork when artwork is missing" do
    record = create(
      :record,
      artwork_url: nil
    )

    render_inline(
      described_class.new(
        record: record
      )
    )

    expect(page).not_to have_css(
      "img"
    )
  end
end
