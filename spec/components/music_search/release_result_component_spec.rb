# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicSearch::ReleaseResultComponent,
               type: :component do
  let(:release) do
    {
      "id" => "test-release-id",
      "title" => "Midnight Marauders",
      "primary-type" => "Album",
      "first-release-date" => "1993-11-09",
      "artist-credit" => [
        {
          "name" => "A Tribe Called Quest"
        }
      ]
    }
  end

  it "renders release information" do
    render_inline(
      described_class.new(
        release: release
      )
    )

    expect(page).to have_content(
      "Midnight Marauders"
    )

    expect(page).to have_content(
      "A Tribe Called Quest"
    )

    expect(page).to have_content(
      "Album"
    )

    expect(page).to have_content(
      "1993-11-09"
    )

    expect(page).to have_button(
      "Add to My Collection"
    )
  end

  it "renders fallback values for missing information" do
    release["primary-type"] = nil
    release["first-release-date"] = nil
    release["artist-credit"] = []

    render_inline(
      described_class.new(
        release: release
      )
    )

    expect(page).to have_content(
      "Unknown Artist"
    )

    expect(page).to have_content(
      "Unknown"
    )
  end

  it "renders the Cover Art Archive image" do
    render_inline(
      described_class.new(
        release: release
      )
    )

    expect(page).to have_css(
      "img[src='https://coverartarchive.org/release-group/test-release-id/front-250']"
    )
  end
end
