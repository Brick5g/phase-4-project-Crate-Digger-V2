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
    it "shows the genre selection page for a logged in user" do
      log_in_user

      record = create(
        :record,
        title: "Midnight Marauders"
      )

      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      get "/records/#{record.id}/record_genres/new"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Choose Release Genres"
      )

      expect(response.body).to include(
        record.title
      )

      expect(response.body).to include(
        genre.name
      )
    end

    it "redirects a logged out user to login" do
      record = create(:record)

      get "/records/#{record.id}/record_genres/new"

      expect(response).to redirect_to(
        login_path
      )
    end
  end

  describe "POST /records/:record_id/record_genres" do
    it "adds a primary genre to the selected record" do
      log_in_user

      record = create(:record)

      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records/#{record.id}/record_genres", params: {
          primary_genre_id: genre.id,
          subgenre_ids: [],
          new_genre_name: ""
        }
      }.to change(
        RecordGenre,
        :count
      ).by(1)

      record_genre = record.record_genres.last

      expect(
        record_genre.genre
      ).to eq(
        genre
      )

      expect(
        record_genre.primary_genre
      ).to be(true)

      expect(response).to redirect_to(
        record_path(record)
      )
    end

    it "adds additional genres to the selected record" do
      log_in_user

      record = create(:record)

      primary_genre = create(
        :genre,
        name: "Hip-Hop"
      )

      additional_genre = create(
        :genre,
        name: "Jazz Rap"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: primary_genre.id,
        subgenre_ids: [
          additional_genre.id
        ],
        new_genre_name: ""
      }

      primary_record_genre =
        record.record_genres.find_by(
          genre: primary_genre
        )

      additional_record_genre =
        record.record_genres.find_by(
          genre: additional_genre
        )

      expect(
        primary_record_genre.primary_genre
      ).to be(true)

      expect(
        additional_record_genre.primary_genre
      ).to be(false)
    end

    it "does not add the same genre to a record twice" do
      log_in_user

      record = create(:record)

      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: genre.id,
        subgenre_ids: [
          genre.id
        ],
        new_genre_name: ""
      }

      expect(
        record.record_genres.where(
          genre: genre
        ).count
      ).to eq(1)
    end

    it "replaces the previous genre selections when genres are updated" do
      log_in_user

      record = create(:record)

      old_genre = create(
        :genre,
        name: "Jazz"
      )

      new_genre = create(
        :genre,
        name: "Hip-Hop"
      )

      create(
        :record_genre,
        record: record,
        genre: old_genre,
        primary_genre: true
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: new_genre.id,
        subgenre_ids: [],
        new_genre_name: ""
      }

      expect(
        record.reload.genres
      ).to include(
        new_genre
      )

      expect(
        record.genres
      ).not_to include(
        old_genre
      )

      expect(
        record.record_genres.find_by(
          genre: new_genre
        ).primary_genre
      ).to be(true)
    end

    it "redirects a logged out user to login" do
      record = create(:record)

      genre = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records/#{record.id}/record_genres", params: {
        primary_genre_id: genre.id,
        subgenre_ids: [],
        new_genre_name: ""
      }

      expect(response).to redirect_to(
        login_path
      )

      expect(
        record.record_genres.count
      ).to eq(0)
    end
  end
end
