require "net/http"
require "json"

class MusicBrainzService
  BASE_URL = "https://musicbrainz.org/ws/2"
  USER_AGENT =
    "CrateDiggerV2/1.0 (https://github.com/Brick5g/phase-4-project-Crate-Digger-V2)"

  def initialize
    @last_request_time = nil
  end

  def search_artists(query)
    uri = build_uri(
      "artist",
      query: "artist:#{query}",
      fmt: "json",
      limit: 10
    )

    data = request(
      uri
    )

    data.fetch(
      "artists",
      []
    )
  end

  def search_releases(query)
    uri = build_uri(
      "release-group",
      query: query,
      fmt: "json",
      limit: 25
    )

    data = request(
      uri
    )

    data.fetch(
      "release-groups",
      []
    )
  end

  def fetch_artist(artist_id)
    uri = build_uri(
      "artist/#{artist_id}",
      fmt: "json"
    )

    request(
      uri
    )
  end

  def fetch_all_artist_releases(artist_id)
    releases = []
    offset = 0
    total = nil

    loop do
      uri = build_uri(
        "release-group",
        artist: artist_id,
        fmt: "json",
        limit: 100,
        offset: offset,
        inc: "artist-credits"
      )

      data = request(
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
    end

    releases.sort_by do |release|
      release["first-release-date"].to_s
    end.reverse
  end

  def fetch_release_group(release_id)
    uri = build_uri(
      "release-group/#{release_id}",
      fmt: "json",
      inc: "artist-credits+genres"
    )

    request(
      uri
    )
  end

  private

  def build_uri(path, parameters)
    uri = URI(
      "#{BASE_URL}/#{path}"
    )

    uri.query = URI.encode_www_form(
      parameters
    )

    uri
  end

  def request(uri)
    respect_rate_limit

    request = Net::HTTP::Get.new(
      uri
    )

    request["User-Agent"] =
      USER_AGENT

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(
        request
      )
    end

    @last_request_time =
      Process.clock_gettime(
        Process::CLOCK_MONOTONIC
      )

    unless response.is_a?(
      Net::HTTPSuccess
    )
      raise "MusicBrainz request failed"
    end

    JSON.parse(
      response.body
    )
  end

  def respect_rate_limit
    return if @last_request_time.nil?

    elapsed =
      Process.clock_gettime(
        Process::CLOCK_MONOTONIC
      ) - @last_request_time

    remaining =
      1.0 - elapsed

    Kernel.sleep(
      remaining
    ) if remaining.positive?
  end
end
