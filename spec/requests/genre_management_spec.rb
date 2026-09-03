require "rails_helper"

RSpec.describe "Genre Management", type: :request do
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

  describe "release genres" do
    it "requires login to manage release genres" do
      record = create(:record)

      get "/records/#{record.id}/record_genres/new"

      expect(response).to redirect_to(
        login_path
      )
    end

    it "shows the release genre form" do
      log_in_user

      record = create(
        :record,
        title: "Midnight Marauders"
      )

      create(
        :genre,
        name: "Hip-Hop"
      )

      get "/records/#{record.id}/record_genres/new"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Choose Release Genres"
      )

      expect(response.body).to include(
        "Midnight Marauders"
      )

      expect(response.body).to include(
        "Hip-Hop"
      )
    end

    it "saves one primary genre and multiple additional genres" do
      log_in_user

      record = create(:record)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      jazz = create(
        :genre,
        name: "Jazz"
      )

      rap = create(
        :genre,
        name: "Rap"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: hip_hop.id,
        subgenre_ids: [
          jazz.id,
          rap.id
        ],
        new_genre_name: ""
      }

      primary_genre =
        record.record_genres.find_by(
          primary_genre: true
        )

      additional_genres =
        record.record_genres.where(
          primary_genre: false
        )

      expect(
        primary_genre.genre
      ).to eq(
        hip_hop
      )

      expect(
        additional_genres.map(&:genre)
      ).to contain_exactly(
        jazz,
        rap
      )

      expect(response).to redirect_to(
        record_path(record)
      )
    end

    it "creates a missing genre as an additional genre" do
      log_in_user

      record = create(:record)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: hip_hop.id,
        subgenre_ids: [],
        new_genre_name: "Neo Soul"
      }

      neo_soul = Genre.find_by(
        name: "Neo Soul"
      )

      expect(
        neo_soul
      ).to be_present

      association =
        record.record_genres.find_by(
          genre: neo_soul
        )

      expect(
        association.primary_genre
      ).to be(false)
    end

    it "uses a new genre as primary when no primary was selected" do
      log_in_user

      record = create(:record)

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: "",
        subgenre_ids: [],
        new_genre_name: "Neo Soul"
      }

      primary_genre =
        record.record_genres.find_by(
          primary_genre: true
        )

      expect(
        primary_genre.genre.name
      ).to eq(
        "Neo Soul"
      )
    end

    it "does not create a duplicate genre with different formatting" do
      log_in_user

      record = create(:record)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records/#{record.id}/record_genres", params: {
          primary_genre_id: "",
          subgenre_ids: [],
          new_genre_name: "hip_hop"
        }
      }.not_to change(
        Genre,
        :count
      )

      expect(
        record.reload.genres
      ).to include(
        hip_hop
      )
    end

    it "rejects typing the same genre as the selected primary genre" do
      log_in_user

      record = create(:record)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: hip_hop.id,
        subgenre_ids: [],
        new_genre_name: "hip hop"
      }

      expect(response).to have_http_status(
        :unprocessable_content
      )

      expect(response.body).to include(
        "cannot be the same as the primary genre"
      )
    end
  end

  describe "artist genres" do
    it "shows genre options on the artist edit page" do
      log_in_user

      artist = create(
        :artist,
        name: "Drake"
      )

      create(
        :genre,
        name: "Hip-Hop"
      )

      get "/artists/#{artist.id}/edit"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Primary Genre"
      )

      expect(response.body).to include(
        "Additional Genres"
      )

      expect(response.body).to include(
        "Hip-Hop"
      )
    end

    it "saves one primary artist genre and multiple additional genres" do
      log_in_user

      artist = create(
        :artist,
        name: "Drake"
      )

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      r_and_b = create(
        :genre,
        name: "R&B"
      )

      rap = create(
        :genre,
        name: "Rap"
      )

      house = create(
        :genre,
        name: "House"
      )

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: "Drake",
          country: "Canada",
          hometown: "Toronto"
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [
          r_and_b.id,
          rap.id,
          house.id
        ],
        new_genre_name: ""
      }

      primary_genre =
        artist.artist_genres.find_by(
          primary_genre: true
        )

      additional_genres =
        artist.artist_genres.where(
          primary_genre: false
        )

      expect(
        primary_genre.genre
      ).to eq(
        hip_hop
      )

      expect(
        additional_genres.map(&:genre)
      ).to contain_exactly(
        r_and_b,
        rap,
        house
      )

      expect(response).to redirect_to(
        artist_path(artist)
      )
    end

    it "creates a missing artist genre" do
      log_in_user

      artist = create(
        :artist,
        name: "Drake"
      )

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: "Drake"
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [],
        new_genre_name: "House"
      }

      house = Genre.find_by(
        name: "House"
      )

      expect(
        house
      ).to be_present

      association =
        artist.artist_genres.find_by(
          genre: house
        )

      expect(
        association.primary_genre
      ).to be(false)
    end
  end
end
