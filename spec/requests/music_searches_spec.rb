require "rails_helper"

RSpec.describe "MusicSearches", type: :request do
  def log_in_user
    user = create(
      :user,
      password: "password",
      password_confirmation: "password"
    )

    post "/login", params: {
      email: user.email,
      password: "password"
    }

    user
  end

  describe "GET /music-search" do
    it "redirects logged out users to login" do
      get "/music-search"

      expect(response).to redirect_to(login_path)
    end

    it "shows the search page to a logged in user" do
      log_in_user

      get "/music-search"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Find Music"
      )

      expect(response.body).to include(
        "Search Music"
      )
    end
  end

  describe "GET /music-search/artists/:musicbrainz_id" do
    it "redirects logged out users to login" do
      get "/music-search/artists/test-artist-id"

      expect(response).to redirect_to(login_path)
    end
  end

  describe "POST /music-search/releases/:musicbrainz_id" do
    let(:release_data) do
      {
        "id" => "release-group-123",
        "title" => "Midnight Marauders",
        "first-release-date" => "1993-11-09",
        "primary-type" => "Album",
        "artist-credit" => [
          {
            "name" => "A Tribe Called Quest",
            "artist" => {
              "id" => "artist-123",
              "name" => "A Tribe Called Quest"
            }
          }
        ]
      }
    end

    it "redirects logged out users to login" do
      post "/music-search/releases/release-group-123"

      expect(response).to redirect_to(login_path)
    end

    it "creates the artist, release, and collection entry" do
      user = log_in_user

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.to change(Artist, :count).by(1)
        .and change(Record, :count).by(1)
        .and change(CollectionEntry, :count).by(1)

      artist = Artist.last
      record = Record.last
      collection_entry = CollectionEntry.last

      expect(artist.name).to eq(
        "A Tribe Called Quest"
      )

      expect(artist.musicbrainz_id).to eq(
        "artist-123"
      )

      expect(record.title).to eq(
        "Midnight Marauders"
      )

      expect(record.musicbrainz_id).to eq(
        "release-group-123"
      )

      expect(record.release_type).to eq(
        "Album"
      )

      expect(record.release_date).to eq(
        Date.new(1993, 11, 9)
      )

      expect(record.artist).to eq(artist)

      expect(collection_entry.user).to eq(user)
      expect(collection_entry.record).to eq(record)

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "reuses an existing artist with the same name" do
      log_in_user

      existing_artist = create(
        :artist,
        name: "A Tribe Called Quest",
        musicbrainz_id: nil
      )

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.not_to change(Artist, :count)

      existing_artist.reload

      expect(existing_artist.musicbrainz_id).to eq(
        "artist-123"
      )

      expect(Record.last.artist).to eq(
        existing_artist
      )
    end

    it "reuses an existing artist regardless of capitalization" do
      log_in_user

      existing_artist = create(
        :artist,
        name: "A TRIBE CALLED QUEST",
        musicbrainz_id: nil
      )

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.not_to change(Artist, :count)

      existing_artist.reload

      expect(existing_artist.musicbrainz_id).to eq(
        "artist-123"
      )
    end

    it "reuses an existing release with the same MusicBrainz ID" do
      user = log_in_user

      artist = create(
        :artist,
        name: "A Tribe Called Quest",
        musicbrainz_id: "artist-123"
      )

      existing_record = create(
        :record,
        artist: artist,
        title: "Midnight Marauders",
        musicbrainz_id: "release-group-123"
      )

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.not_to change(Record, :count)

      expect(
        user.collection_entries.last.record
      ).to eq(
        existing_record
      )
    end

    it "does not save the same release twice for one user" do
      user = log_in_user

      artist = create(
        :artist,
        name: "A Tribe Called Quest",
        musicbrainz_id: "artist-123"
      )

      record = create(
        :record,
        artist: artist,
        title: "Midnight Marauders",
        musicbrainz_id: "release-group-123"
      )

      create(
        :collection_entry,
        user: user,
        record: record
      )

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.not_to change(CollectionEntry, :count)

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "allows different users to save the same imported release" do
      first_user = log_in_user

      artist = create(
        :artist,
        name: "A Tribe Called Quest",
        musicbrainz_id: "artist-123"
      )

      record = create(
        :record,
        artist: artist,
        title: "Midnight Marauders",
        musicbrainz_id: "release-group-123"
      )

      create(
        :collection_entry,
        user: first_user,
        record: record
      )

      delete "/logout"

      second_user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      post "/login", params: {
        email: second_user.email,
        password: "password"
      }

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        release_data
      )

      expect {
        post "/music-search/releases/release-group-123"
      }.to change(CollectionEntry, :count).by(1)

      expect(
        second_user.collection_entries.last.record
      ).to eq(
        record
      )
    end

    it "does not invent a complete date when MusicBrainz only provides a year" do
      log_in_user

      incomplete_date_release = release_data.merge(
        "first-release-date" => "1993"
      )

      allow_any_instance_of(
        MusicSearchesController
      ).to receive(
        :fetch_release_group
      ).and_return(
        incomplete_date_release
      )

      post "/music-search/releases/release-group-123"

      expect(
        Record.last.release_date
      ).to be_nil
    end
  end
end
