require "rails_helper"

RSpec.describe "Genres", type: :request do
  describe "GET /genres" do
    it "returns a successful response" do
      get "/genres"

      expect(response).to have_http_status(:ok)
    end

    it "shows existing genres" do
      create(:genre, name: "Hip-Hop")

      get "/genres"

      expect(response.body).to include("Hip-Hop")
    end
  end

  describe "GET /genres/:id" do
    it "shows the selected genre" do
      genre = create(
        :genre,
        name: "Jazz",
        description: "Jazz records"
      )

      get "/genres/#{genre.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jazz")
      expect(response.body).to include("Jazz records")
    end

    it "shows records associated with the genre" do
      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      record = create(
        :record,
        title: "Midnight Marauders"
      )

      create(
        :record_genre,
        genre: genre,
        record: record
      )

      get "/genres/#{genre.id}"

      expect(response.body).to include("Midnight Marauders")
    end
  end

  describe "GET /genres/new" do
    it "shows the new genre form" do
      get "/genres/new"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /genres" do
    it "creates a genre with valid information" do
      expect {
        post "/genres", params: {
          genre: {
            name: "Soul",
            description: "Soul records"
          }
        }
      }.to change(Genre, :count).by(1)

      genre = Genre.last

      expect(genre.name).to eq("Soul")
      expect(response).to redirect_to(genre_path(genre))
    end

    it "does not create an invalid genre" do
      expect {
        post "/genres", params: {
          genre: {
            name: "",
            description: ""
          }
        }
      }.not_to change(Genre, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "GET /genres/:id/edit" do
    it "shows the edit form" do
      genre = create(:genre, name: "Jazz")

      get "/genres/#{genre.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jazz")
    end
  end

  describe "PATCH /genres/:id" do
    it "updates a genre with valid information" do
      genre = create(:genre, name: "Old Genre")

      patch "/genres/#{genre.id}", params: {
        genre: {
          name: "New Genre"
        }
      }

      genre.reload

      expect(genre.name).to eq("New Genre")
      expect(response).to redirect_to(genre_path(genre))
    end

    it "does not update a genre with invalid information" do
      genre = create(:genre, name: "Jazz")

      patch "/genres/#{genre.id}", params: {
        genre: {
          name: ""
        }
      }

      genre.reload

      expect(genre.name).to eq("Jazz")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "DELETE /genres/:id" do
    it "deletes the selected genre" do
      genre = create(:genre)

      expect {
        delete "/genres/#{genre.id}"
      }.to change(Genre, :count).by(-1)

      expect(response).to redirect_to(genres_path)
    end
  end
end
