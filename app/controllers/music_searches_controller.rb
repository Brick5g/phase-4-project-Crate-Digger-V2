require "net/http"
require "json"
require "date"

class MusicSearchesController < ApplicationController
  before_action :require_login

  def index
    @query = params[:query].to_s.strip
    @artist_results = []
    @release_results = []

    return if @query.blank?

    @artist_results = search_artists(@query)

    sleep 1

    @release_results = search_releases(@query)
  rescue StandardError => error
    Rails.logger.error(
      "MusicBrainz search failed: #{error.class} - #{error.message}"
    )

    @error = "Music search is temporarily unavailable. Please try again."
  end

  def artist
    @artist_id = params[:musicbrainz_id]

    artist_data = fetch_artist(
      @artist_id
    )

    @artist_name = artist_data["name"]
    @artist_country = artist_data["country"]

    sleep 1

    @release_results = fetch_all_artist_releases(
      @artist_id
    )
  rescue StandardError => error
    Rails.logger.error(
      "MusicBrainz artist search failed: #{error.class} - #{error.message}"
    )

    @error = "We could not load this artist's releases right now."
    @release_results = []
  end

  def import
    release_id = params[:musicbrainz_id]

    release_data = fetch_release_group(
      release_id
    )

    artist_data = artist_data_from(
      release_data
    )

    if artist_data.nil?
      redirect_to(
        music_search_path,
        alert: "We could not identify the artist for this release."
      )

      return
    end

    artist = find_or_create_artist(
      artist_data
    )

    record = find_or_create_record(
      release_data,
      artist
    )

    import_release_genres(
      release_data,
      record
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

  def search_artists(query)
    uri = URI(
      "https://musicbrainz.org/ws/2/artist"
    )

    uri.query = URI.encode_www_form(
      query: "artist:#{query}",
      fmt: "json",
      limit: 10
    )

    data = musicbrainz_request(
      uri
    )

    data.fetch(
      "artists",
      []
    )
  end

  def search_releases(query)
    uri = URI(
      "https://musicbrainz.org/ws/2/release-group"
    )

    uri.query = URI.encode_www_form(
      query: query,
      fmt: "json",
      limit: 25
    )

    data = musicbrainz_request(
      uri
    )

    data.fetch(
      "release-groups",
      []
    )
  end

  def fetch_artist(artist_id)
    uri = URI(
      "https://musicbrainz.org/ws/2/artist/#{artist_id}"
    )

    uri.query = URI.encode_www_form(
      fmt: "json"
    )

    musicbrainz_request(
      uri
    )
  end

  def fetch_all_artist_releases(artist_id)
    releases = []
    offset = 0
    total = nil

    loop do
      uri = URI(
        "https://musicbrainz.org/ws/2/release-group"
      )

      uri.query = URI.encode_www_form(
        artist: artist_id,
        fmt: "json",
        limit: 100,
        offset: offset,
        inc: "artist-credits"
      )

      data = musicbrainz_request(
        uri
      )

      page = data.fetch(
        "release-groups",
        []
      )

      releases.concat(
        page
      )

      total ||= data.fetch(
        "release-group-count",
        0
      ).to_i

      offset += page.length

      break if page.empty?
      break if offset >= total

      sleep 1
    end

    releases.sort_by do |release|
      release["first-release-date"].to_s
    end.reverse
  end

  def fetch_release_group(release_id)
    uri = URI(
      "https://musicbrainz.org/ws/2/release-group/#{release_id}"
    )

    uri.query = URI.encode_www_form(
      fmt: "json",
      inc: "artist-credits+genres"
    )

    musicbrainz_request(
      uri
    )
  end

  def musicbrainz_request(uri)
    request = Net::HTTP::Get.new(
      uri
    )

    request["User-Agent"] =
      "CrateDiggerV2/1.0 (https://github.com/Brick5g/phase-4-project-Crate-Digger-V2)"

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(
        request
      )
    end

    unless response.is_a?(
      Net::HTTPSuccess
    )
      raise "MusicBrainz request failed"
    end

    JSON.parse(
      response.body
    )
  end

  def artist_data_from(release_data)
    artist_credit = release_data.fetch(
      "artist-credit",
      []
    ).first

    return if artist_credit.nil?

    artist_data = artist_credit["artist"]

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

  def find_or_create_artist(artist_data)
    musicbrainz_id = artist_data["id"]
    artist_name = artist_data["name"]

    raise "Artist name is missing" if artist_name.blank?

    artist = find_artist_by_musicbrainz_id(
      musicbrainz_id
    )

    artist ||= find_artist_by_name(
      artist_name
    )

    if artist
      update_existing_artist(
        artist,
        artist_data
      )

      return artist
    end

    Artist.create!(
      name: artist_name,
      country: artist_data["country"],
      musicbrainz_id: musicbrainz_id
    )
  end

  def find_artist_by_musicbrainz_id(musicbrainz_id)
    return if musicbrainz_id.blank?

    Artist.find_by(
      musicbrainz_id: musicbrainz_id
    )
  end

  def find_artist_by_name(artist_name)
    Artist.all.find do |artist|
      normalize_text(
        artist.name
      ) == normalize_text(
        artist_name
      )
    end
  end

  def update_existing_artist(artist, artist_data)
    updates = {}

    if artist.musicbrainz_id.blank? &&
       artist_data["id"].present?
      updates[:musicbrainz_id] =
        artist_data["id"]
    end

    api_name = artist_data["name"]

    if api_name.present? &&
       artist.name != api_name
      updates[:name] =
        api_name
    end

    if artist.country.blank? &&
       artist_data["country"].present?
      updates[:country] =
        artist_data["country"]
    end

    artist.update!(
      updates
    ) if updates.any?
  end

  def find_or_create_record(release_data, artist)
    musicbrainz_id = release_data["id"]

    record = find_record_by_musicbrainz_id(
      musicbrainz_id
    )

    record ||= find_record_by_title(
      release_data["title"],
      artist
    )

    if record
      update_existing_record(
        record,
        release_data
      )

      return record
    end

    Record.create!(
      title: release_data["title"],
      artist: artist,
      release_date: complete_release_date(
        release_data["first-release-date"]
      ),
      release_type: release_data["primary-type"].presence || "Other",
      musicbrainz_id: musicbrainz_id,
      artwork_url: artwork_url(
        musicbrainz_id
      )
    )
  end

  def find_record_by_musicbrainz_id(musicbrainz_id)
    return if musicbrainz_id.blank?

    Record.find_by(
      musicbrainz_id: musicbrainz_id
    )
  end

  def find_record_by_title(title, artist)
    return if title.blank?

    artist.records.find do |record|
      normalize_text(
        record.title
      ) == normalize_text(
        title
      )
    end
  end

  def update_existing_record(record, release_data)
    updates = {}

    if record.musicbrainz_id.blank? &&
       release_data["id"].present?
      updates[:musicbrainz_id] =
        release_data["id"]
    end

    if release_data["title"].present?
      updates[:title] =
        release_data["title"]
    end

    if release_data["primary-type"].present?
      updates[:release_type] =
        release_data["primary-type"]
    end

    complete_date = complete_release_date(
      release_data["first-release-date"]
    )

    if complete_date.present?
      updates[:release_date] =
        complete_date
    end

    if release_data["id"].present?
      updates[:artwork_url] =
        artwork_url(
          release_data["id"]
        )
    end

    record.update!(
      updates
    ) if updates.any?
  end

  def import_release_genres(release_data, record)
    genre_data = release_data.fetch(
      "genres",
      []
    )

    genre_data.each do |genre_information|
      genre_name = genre_information["name"].to_s.strip

      next if genre_name.blank?

      genre = find_or_create_genre(
        genre_name
      )

      record.record_genres.find_or_create_by!(
        genre: genre
      ) do |record_genre|
        record_genre.primary_genre = false
      end
    end
  end

  def find_or_create_genre(genre_name)
    existing_genre = Genre.all.find do |genre|
      normalize_genre_name(
        genre.name
      ) == normalize_genre_name(
        genre_name
      )
    end

    return existing_genre if existing_genre

    Genre.create!(
      name: genre_name.titleize,
      description: "Imported from MusicBrainz."
    )
  end

  def normalize_genre_name(name)
    name.to_s
        .downcase
        .tr("_-", "  ")
        .squish
  end

  def normalize_text(text)
    text.to_s
        .tr("_", " ")
        .squish
        .downcase
  end

  def complete_release_date(date_string)
    return if date_string.blank?

    return unless date_string.match?(
      /\A\d{4}-\d{2}-\d{2}\z/
    )

    Date.parse(
      date_string
    )
  end

  def artwork_url(release_id)
    return if release_id.blank?

    "https://coverartarchive.org/release-group/#{release_id}/front-500"
  end
end
