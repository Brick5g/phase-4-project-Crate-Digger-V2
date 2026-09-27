# frozen_string_literal: true

require "rails_helper"

RSpec.describe AlbumWallComponent, type: :component do
  it "renders album artwork" do
    record = create(
      :record,
      title: "Test Album",
      artwork_url: "https://example.com/cover.jpg"
    )

    render_inline(
      described_class.new(
        records: [ record ]
      )
    )

    expect(page).to have_css(
      "img[src='https://example.com/cover.jpg']",
      count: 4
    )

    expect(page).to have_css(
      "img[alt='Test Album album cover']"
    )
  end

  it "renders both album wall columns" do
    record = create(
      :record,
      artwork_url: "https://example.com/cover.jpg"
    )

    render_inline(
      described_class.new(
        records: [ record ]
      )
    )

    expect(page).to have_css(
      ".album-column-one"
    )

    expect(page).to have_css(
      ".album-column-two"
    )
  end

  it "renders the empty state without records" do
    render_inline(
      described_class.new(
        records: []
      )
    )

    expect(page).to have_content(
      "Album artwork will appear here"
    )

    expect(page).not_to have_css(
      ".album-cover"
    )
  end
end
