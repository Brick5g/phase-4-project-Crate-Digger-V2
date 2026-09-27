# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicSearch::ArtistResultComponent,
               type: :component do
  let(:artist) do
    {
      "id" => "test-artist-id",
      "name" => "A Tribe Called Quest",
      "disambiguation" => "American hip hop group",
      "country" => "US",
      "score" => 100
    }
  end

  it "renders artist information" do
    render_inline(
      described_class.new(
        artist: artist
      )
    )

    expect(page).to have_content(
      "A Tribe Called Quest"
    )

    expect(page).to have_content(
      "American hip hop group"
    )

    expect(page).to have_content(
      "US"
    )

    expect(page).to have_content(
      "100"
    )

    expect(page).to have_link(
      "View All Releases"
    )
  end

  it "does not render optional information when it is missing" do
    artist["disambiguation"] = nil
    artist["country"] = nil

    render_inline(
      described_class.new(
        artist: artist
      )
    )

    expect(page).not_to have_content(
      "American hip hop group"
    )

    expect(page).not_to have_content(
      "Country:"
    )

    expect(page).to have_content(
      "MusicBrainz Match Score:"
    )
  end
end
