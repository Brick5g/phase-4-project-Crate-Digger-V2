require "rails_helper"

RSpec.describe "RecordGenres", type: :request do
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

  describe "GET /records/:record_id/record_genres/new" do
    it "shows the form for adding a genre to a record" do
      log_in_user

      record = create(:record)
      create(:genre, name: "Hip-Hop")

      get "/records/#{record.id}/record_genres/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(record.title)
      expect(response.body).to include("Hip-Hop")
    end
  end

  describe "POST /records/:record_id/record_genres" do
    it "adds a genre to the selected record" do
      log_in_user

      record = create(:record)
      genre = create(:genre)

      expect {
        post "/records/#{record.id}/record_genres", params: {
          record_genre: {
            genre_id: genre.id,
            primary_genre: true,
            notes: "Primary genre"
          }
        }
      }.to change(RecordGenre, :count).by(1)

      record_genre = RecordGenre.last

      expect(record_genre.record).to eq(record)
      expect(record_genre.genre).to eq(genre)
      expect(response).to redirect_to(record_path(record))
    end

    it "does not add the same genre to a record twice" do
      log_in_user

      record = create(:record)
      genre = create(:genre)

      create(
        :record_genre,
        record: record,
        genre: genre
      )

      expect {
        post "/records/#{record.id}/record_genres", params: {
          record_genre: {
            genre_id: genre.id,
            primary_genre: false,
            notes: "Duplicate"
          }
        }
      }.not_to change(RecordGenre, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /record_genres/:id" do
    it "removes a genre from a record" do
      log_in_user

      record_genre = create(:record_genre)
      record = record_genre.record

      expect {
        delete "/record_genres/#{record_genre.id}"
      }.to change(RecordGenre, :count).by(-1)

      expect(response).to redirect_to(record_path(record))
    end
  end
end
