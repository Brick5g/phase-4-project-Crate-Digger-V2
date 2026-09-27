# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenreTagComponent, type: :component do
  it "renders the genre name" do
    record_genre = create(
      :record_genre
    )

    render_inline(
      described_class.new(
        record_genre: record_genre
      )
    )

    expect(page).to have_content(
      record_genre.genre.name
    )
  end

  it "labels a primary genre" do
    record_genre = create(
      :record_genre,
      primary_genre: true
    )

    render_inline(
      described_class.new(
        record_genre: record_genre
      )
    )

    expect(page).to have_content(
      "Primary"
    )
  end

  it "does not label an additional genre as primary" do
    record_genre = create(
      :record_genre,
      primary_genre: false
    )

    render_inline(
      described_class.new(
        record_genre: record_genre
      )
    )

    expect(page).not_to have_content(
      "Primary"
    )
  end
end
