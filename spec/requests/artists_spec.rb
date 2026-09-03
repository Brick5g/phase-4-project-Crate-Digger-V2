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

    it "shows existing artists" do
      create(:artist, name: "A Tribe Called Quest")

      get "/artists"

      expect(response.body).to include("A Tribe Called Quest")
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
      expect(response.body).to include("A Tribe Called Quest")
      expect(response.body).to include("United States")
    end

    it "shows records that belong to the artist" do
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

      expect(response.body).to include("Midnight Marauders")
    end
  end

  describe "GET /artists/new" do
    it "shows the new artist form to a logged in user" do
      log_in_user

      get "/artists/new"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /artists" do
    it "creates an artist with valid information" do
      log_in_user

      expect {
        post "/artists", params: {
          artist: {
            name: "Nas",
            country: "United States"
          }
        }
      }.to change(Artist, :count).by(1)

      artist = Artist.last

      expect(artist.name).to eq("Nas")
      expect(response).to redirect_to(artist_path(artist))
    end

    it "does not create an artist with invalid information" do
      log_in_user

      expect {
        post "/artists", params: {
          artist: {
            name: "",
            country: ""
          }
        }
      }.not_to change(Artist, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "GET /artists/:id/edit" do
    it "shows the edit form for the selected artist" do
      log_in_user

      artist = create(:artist, name: "Nas")

      get "/artists/#{artist.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nas")
    end
  end

  describe "PATCH /artists/:id" do
    it "updates an artist with valid information" do
      log_in_user

      artist = create(:artist, name: "Old Name")

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: "New Name"
        }
      }

      artist.reload

      expect(artist.name).to eq("New Name")
      expect(response).to redirect_to(artist_path(artist))
    end

    it "does not update an artist with invalid information" do
      log_in_user

      artist = create(:artist, name: "Original Name")

      patch "/artists/#{artist.id}", params: {
        artist: {
          name: ""
        }
      }

      artist.reload

      expect(artist.name).to eq("Original Name")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "DELETE /artists/:id" do
    it "deletes the selected artist" do
      log_in_user

      artist = create(:artist)

      expect {
        delete "/artists/#{artist.id}"
      }.to change(Artist, :count).by(-1)

      expect(response).to redirect_to(artists_path)
    end
  end
end
