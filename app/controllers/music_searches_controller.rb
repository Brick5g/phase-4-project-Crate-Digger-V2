class MusicSearchesController < ApplicationController
  before_action :require_login

  def index
    @query =
      params[:query].to_s.strip

    @artist_results = []
    @release_results = []

    return if @query.blank?

    service =
      MusicBrainzService.new

    @artist_results =
      service.search_artists(
        @query
      )

    @release_results =
      service.search_releases(
        @query
      )
  rescue StandardError => error
    Rails.logger.error(
      "MusicBrainz search failed: #{error.class} - #{error.message}"
    )

    @error =
      "Music search is temporarily unavailable. Please try again."
  end

  def artist
    @artist_id =
      params[:musicbrainz_id]

    service =
      MusicBrainzService.new

    artist_data =
      service.fetch_artist(
        @artist_id
      )

    @artist_name =
      artist_data["name"]

    @artist_country =
      artist_data["country"]

    @release_results =
      service.fetch_all_artist_releases(
        @artist_id
      )
  rescue StandardError => error
    Rails.logger.error(
      "MusicBrainz artist search failed: #{error.class} - #{error.message}"
    )

    @error =
      "We could not load this artist's releases right now."

    @release_results = []
  end

  def import
    service =
      MusicBrainzService.new

    release_data =
      service.fetch_release_group(
        params[:musicbrainz_id]
      )

    artist_data =
      artist_data_from(
        release_data
      )

    if artist_data.nil?
      redirect_to(
        music_search_path,
        alert: "We could not identify the artist for this release."
      )

      return
    end

    artist =
      Artist.find_or_import_from_musicbrainz!(
        artist_data
      )

    record =
      Record.find_or_import_from_musicbrainz!(
        release_data,
        artist
      )

    record.import_musicbrainz_genres!(
      release_data
    )

    current_user.collection_entries.find_or_create_by!(
      record: record
    )

    redirect_to collection_entries_path
  rescue StandardError => error
    Rails.logger.error(
      "MusicBrainz import failed: #{error.class} - #{error.message}"
    )

    redirect_to(
      music_search_path,
      alert: "We could not save that release. Please try again."
    )
  end

  private

  def artist_data_from(release_data)
    artist_credit =
      release_data.fetch(
        "artist-credit",
        []
      ).first

    return if artist_credit.nil?

    artist_data =
      artist_credit["artist"]

    if artist_data.present?
      return {
        "id" => artist_data["id"],
        "name" => artist_data["name"] || artist_credit["name"],
        "country" => artist_data["country"]
      }
    end

    return if artist_credit["name"].blank?

    {
      "id" => artist_credit["id"],
      "name" => artist_credit["name"],
      "country" => artist_credit["country"]
    }
  end
end
