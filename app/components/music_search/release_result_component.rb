# frozen_string_literal: true

class MusicSearch::ReleaseResultComponent < ViewComponent::Base
  def initialize(release:)
    @release = release
  end

  def artist_names
    names =
      @release.fetch(
        "artist-credit",
        []
      ).filter_map do |credit|
        credit["name"]
      end

    names.join(", ").presence || "Unknown Artist"
  end

  def release_type
    @release["primary-type"].presence || "Unknown"
  end

  def release_date
    @release["first-release-date"].presence || "Unknown"
  end

  def artwork_url
    "https://coverartarchive.org/release-group/#{@release["id"]}/front-250"
  end
end
