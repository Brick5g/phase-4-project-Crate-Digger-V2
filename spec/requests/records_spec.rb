require "rails_helper"

RSpec.describe "Records", type: :request do
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

  describe "GET /records" do
    it "returns a successful response" do
      get "/records"

      expect(response).to have_http_status(:ok)
    end

    it "shows records in alphabetical order" do
      create(:record, title: "Zebra")
      create(:record, title: "Abbey Road")
      create(:record, title: "Midnight Marauders")

      get "/records"

      zebra_position = response.body.index("Zebra")
      abbey_position = response.body.index("Abbey Road")
      midnight_position = response.body.index("Midnight Marauders")

      expect(abbey_position).to be < midnight_position
      expect(midnight_position).to be < zebra_position
    end
  end

  describe "GET /records/:id" do
    it "shows the selected record" do
      artist = create(
        :artist,
        name: "A Tribe Called Quest"
      )

      record = create(
        :record,
        title: "The Low End Theory",
        artist: artist,
        release_date: Date.new(1991, 9, 24),
        release_type: "Album"
      )

      get "/records/#{record.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("The Low End Theory")
      expect(response.body).to include("A Tribe Called Quest")
      expect(response.body).to include("Album")
      expect(response.body).to include("1991-09-24")
    end
  end

  describe "GET /records/new" do
    it "redirects logged out users to login" do
      get "/records/new"

      expect(response).to redirect_to(login_path)
    end

    it "shows the new release form to a logged in user" do
      log_in_user

      get "/records/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add a Release")
    end
  end

  describe "POST /records" do
    it "creates a new record with valid information" do
      log_in_user

      artist = create(
        :artist,
        name: "A Tribe Called Quest"
      )

      expect {
        post "/records", params: {
          record: {
            title: "The Low End Theory",
            release_date: "1991-09-24",
            release_type: "Album",
            description: "A classic hip-hop album.",
            artist_id: artist.id
          }
        }
      }.to change(Record, :count).by(1)

      record = Record.last

      expect(record.title).to eq("The Low End Theory")
      expect(record.release_date).to eq(Date.new(1991, 9, 24))
      expect(record.release_type).to eq("Album")
      expect(record.description).to eq("A classic hip-hop album.")
      expect(record.artist).to eq(artist)

      expect(response).to redirect_to(record_path(record))
    end

    it "does not create a record with invalid information" do
      log_in_user

      artist = create(:artist)

      expect {
        post "/records", params: {
          record: {
            title: "",
            release_type: "",
            artist_id: artist.id
          }
        }
      }.not_to change(Record, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title can&#39;t be blank")
      expect(response.body).to include("Release type can&#39;t be blank")
    end
  end

  describe "GET /records/:id/edit" do
    it "shows the edit form to a logged in user" do
      log_in_user

      record = create(
        :record,
        title: "Original Title"
      )

      get "/records/#{record.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Original Title")
    end
  end

  describe "PATCH /records/:id" do
    it "updates a record with valid information" do
      log_in_user

      record = create(
        :record,
        title: "Original Title",
        release_type: "Album"
      )

      patch "/records/#{record.id}", params: {
        record: {
          title: "Updated Title",
          release_type: "EP",
          release_date: "2026-08-01"
        }
      }

      record.reload

      expect(record.title).to eq("Updated Title")
      expect(record.release_type).to eq("EP")
      expect(record.release_date).to eq(Date.new(2026, 8, 1))

      expect(response).to redirect_to(record_path(record))
    end

    it "does not update a record with invalid information" do
      log_in_user

      record = create(
        :record,
        title: "Original Title"
      )

      patch "/records/#{record.id}", params: {
        record: {
          title: "",
          release_type: ""
        }
      }

      record.reload

      expect(record.title).to eq("Original Title")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title can&#39;t be blank")
    end
  end

  describe "DELETE /records/:id" do
    it "deletes the selected record for a logged in user" do
      log_in_user

      record = create(:record)

      expect {
        delete "/records/#{record.id}"
      }.to change(Record, :count).by(-1)

      expect(response).to redirect_to(records_path)
    end
  end
end
