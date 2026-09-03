require "rails_helper"

RSpec.describe "Artists", type: :request do
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

  describe "GET /artists" do
    it "returns a successful response" do
      get "/artists"

      expect(response).to have_http_status(:ok)
    end

    it "shows artists" do
      create(
        :artist,
        name: "A Tribe Called Quest"
      )

      create(
        :artist,
        name: "Larry June"
      )

      get "/artists"

      expect(response.body).to include(
        "A Tribe Called Quest"
      )

      expect(response.body).to include(
        "Larry June"
      )
    end
  end

  describe "GET /artists/:id" do
    it "shows the selected artist" do
      artist = create(
        :artist,
        name: "A Tribe Called Quest",
        country: "United States"
      )

      get "/artists/#{artist.id}"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "A Tribe Called Quest"
      )

      expect(response.body).to include(
        "United States"
      )
    end

    it "shows releases associated with the artist" do
      artist = create(
        :artist,
        name: "A Tribe Called Quest"
      )

      create(
        :record,
        artist: artist,
        title: "Midnight Marauders"
      )

      get "/artists/#{artist.id}"

      expect(response.body).to include(
        "Midnight Marauders"
      )
    end

    it "shows the artist's primary genre" do
      artist = create(:artist)

      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      ArtistGenre.create!(
        artist: artist,
        genre: genre,
        primary_genre: true
      )

      get "/artists/#{artist.id}"

      expect(response.body).to include(
        "Primary Genre"
      )

      expect(response.body).to include(
        "Hip-Hop"
      )
    end

    it "shows additional artist genres" do
      artist = create(:artist)

      primary_genre = create(
        :genre,
        name: "Hip-Hop"
      )

      additional_genre = create(
        :genre,
        name: "R&B"
      )

      ArtistGenre.create!(
        artist: artist,
        genre: primary_genre,
        primary_genre: true
      )

      ArtistGenre.create!(
        artist: artist,
        genre: additional_genre,
        primary_genre: false
      )

      get "/artists/#{artist.id}"

      expect(response.body).to include(
        "Hip-Hop"
      )

      expect(response.body).to include(
        "R&amp;B"
      )
    end

    it "does not show artist management controls when logged out" do
      artist = create(:artist)

      get "/artists/#{artist.id}"

      expect(response.body).not_to include(
        "Edit Artist"
      )

      expect(response.body).not_to include(
        "Delete Artist"
      )
    end

    it "shows artist management controls when logged in" do
      log_in_user

      artist = create(:artist)

      get "/artists/#{artist.id}"

      expect(response.body).to include(
        "Edit Artist"
      )

      expect(response.body).to include(
        "Delete Artist"
      )
    end
  end

  describe "GET /artists/new" do
    it "redirects logged out users to login" do
      get "/artists/new"

      expect(response).to redirect_to(
        login_path
      )
    end

    it "shows the new artist form to a logged in user" do
      log_in_user

      get "/artists/new"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Add"
      )
    end
  end

  describe "POST /artists" do
    it "creates an artist with valid information" do
      log_in_user

      expect {
        post "/artists", params: {
          artist: {
            name: "OutKast",
            country: "United States",
            hometown: "Atlanta",
            details: "Hip-hop duo from Atlanta."
          }
        }
      }.to change(Artist, :count).by(1)

      artist = Artist.last

      expect(artist.name).to eq(
        "OutKast"
      )

      expect(artist.country).to eq(
        "United States"
      )

      expect(artist.hometown).to eq(
        "Atlanta"
      )

      expect(response).to redirect_to(
        artist_path(artist)
      )
    end

    it "does not create an artist without a name" do
      log_in_user

      expect {
        post "/artists", params: {
          artist: {
            name: "",
            country: "United States"
          }
        }
      }.not_to change(Artist, :count)

      expect(response).to have_http_status(
        :unprocessable_content
      )

      expect(response.body).to include(
        "Name can&#39;t be blank"
      )
    end
  end

  describe "GET /artists/:id/edit" do
    it "redirects logged out users to login" do
      artist = create(:artist)

      get "/artists/#{artist.id}/edit"

      expect(response).to redirect_to(
        login_path
      )
    end

    it "shows the edit form to a logged in user" do
      log_in_user

      artist = create(
        :artist,
        name: "Drake"
      )

      get "/artists/#{artist.id}/edit"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Drake"
      )

      expect(response.body).to include(
        "Primary Genre"
      )

      expect(response.body).to include(
        "Additional Genres"
      )
    end
  end

  describe "PATCH /artists/:id" do
    it "updates an artist with valid information" do
      log_in_user

      artist = create(
        :artist,
        name: "Original Name"
      )

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: "Updated Name",
          country: "Canada",
          hometown: "Toronto"
        }
      }

      artist.reload

      expect(artist.name).to eq(
        "Updated Name"
      )

      expect(artist.country).to eq(
        "Canada"
      )

      expect(artist.hometown).to eq(
        "Toronto"
      )

      expect(response).to redirect_to(
        artist_path(artist)
      )
    end

    it "does not update an artist with invalid information" do
      log_in_user

      artist = create(
        :artist,
        name: "Original Name"
      )

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: ""
        }
      }

      artist.reload

      expect(artist.name).to eq(
        "Original Name"
      )

      expect(response).to have_http_status(
        :unprocessable_content
      )
    end

    it "updates the artist's genres" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      r_and_b = create(
        :genre,
        name: "R&B"
      )

      house = create(
        :genre,
        name: "House"
      )

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: artist.name
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [
          r_and_b.id,
          house.id
        ]
      }

      artist.reload

      primary_genre = artist.artist_genres.find_by(
        primary_genre: true
      )

      additional_genres = artist.artist_genres.where(
        primary_genre: false
      )

      expect(primary_genre.genre).to eq(
        hip_hop
      )

      expect(
        additional_genres.map(&:genre)
      ).to contain_exactly(
        r_and_b,
        house
      )
    end
  end

  describe "DELETE /artists/:id" do
    it "redirects logged out users to login" do
      artist = create(:artist)

      delete "/artists/#{artist.id}"

      expect(response).to redirect_to(
        login_path
      )

      expect(
        Artist.exists?(artist.id)
      ).to be(true)
    end

    it "deletes an artist for a logged in user" do
      log_in_user

      artist = create(:artist)

      expect {
        delete "/artists/#{artist.id}"
      }.to change(Artist, :count).by(-1)

      expect(response).to redirect_to(
        artists_path
      )
    end

    it "also removes releases belonging to the deleted artist" do
      log_in_user

      artist = create(:artist)

      create(
        :record,
        artist: artist
      )

      expect {
        delete "/artists/#{artist.id}"
      }.to change(Record, :count).by(-1)
    end
  end
end
