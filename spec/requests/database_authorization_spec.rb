require "rails_helper"

RSpec.describe "Database authorization", type: :request do
  describe "records" do
    it "allows logged out users to browse records" do
      record = create(:record)

      get "/records"

      expect(response).to have_http_status(:ok)

      get "/records/#{record.id}"

      expect(response).to have_http_status(:ok)
    end

    it "requires login to create a record" do
      get "/records/new"

      expect(response).to redirect_to(login_path)

      expect {
        post "/records", params: {
          record: {
            title: "New Record",
            release_year: 2026,
            format: "Album",
            condition: "New",
            artist_id: create(:artist).id
          }
        }
      }.not_to change(Record, :count)

      expect(response).to redirect_to(login_path)
    end

    it "requires login to edit or delete a record" do
      record = create(:record)

      get "/records/#{record.id}/edit"

      expect(response).to redirect_to(login_path)

      expect {
        delete "/records/#{record.id}"
      }.not_to change(Record, :count)

      expect(response).to redirect_to(login_path)
    end
  end

  describe "artists" do
    it "allows logged out users to browse artists" do
      artist = create(:artist)

      get "/artists"

      expect(response).to have_http_status(:ok)

      get "/artists/#{artist.id}"

      expect(response).to have_http_status(:ok)
    end

    it "requires login to create an artist" do
      get "/artists/new"

      expect(response).to redirect_to(login_path)

      expect {
        post "/artists", params: {
          artist: {
            name: "New Artist",
            country: "United States"
          }
        }
      }.not_to change(Artist, :count)

      expect(response).to redirect_to(login_path)
    end

    it "requires login to edit or delete an artist" do
      artist = create(:artist)

      get "/artists/#{artist.id}/edit"

      expect(response).to redirect_to(login_path)

      expect {
        delete "/artists/#{artist.id}"
      }.not_to change(Artist, :count)

      expect(response).to redirect_to(login_path)
    end
  end

  describe "genres" do
    it "allows logged out users to browse genres" do
      genre = create(:genre)

      get "/genres"

      expect(response).to have_http_status(:ok)

      get "/genres/#{genre.id}"

      expect(response).to have_http_status(:ok)
    end

    it "requires login to create a genre" do
      get "/genres/new"

      expect(response).to redirect_to(login_path)

      expect {
        post "/genres", params: {
          genre: {
            name: "New Genre",
            description: "A new genre"
          }
        }
      }.not_to change(Genre, :count)

      expect(response).to redirect_to(login_path)
    end

    it "requires login to edit or delete a genre" do
      genre = create(:genre)

      get "/genres/#{genre.id}/edit"

      expect(response).to redirect_to(login_path)

      expect {
        delete "/genres/#{genre.id}"
      }.not_to change(Genre, :count)

      expect(response).to redirect_to(login_path)
    end
  end

  describe "record genres" do
    it "requires login to add a genre to a record" do
      record = create(:record)
      genre = create(:genre)

      get "/records/#{record.id}/record_genres/new"

      expect(response).to redirect_to(login_path)

      expect {
        post "/records/#{record.id}/record_genres", params: {
          record_genre: {
            genre_id: genre.id,
            primary_genre: true,
            notes: "Primary genre"
          }
        }
      }.not_to change(RecordGenre, :count)

      expect(response).to redirect_to(login_path)
    end
  end
end
