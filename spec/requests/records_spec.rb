require "rails_helper"

RSpec.describe "Records", type: :request do
  describe "GET /records" do
    it "returns a successful response" do
      get "/records"

      expect(response).to have_http_status(:ok)
    end

    it "shows records in alphabetical order" do
      artist = create(:artist)

      create(:record, artist: artist, title: "Zebra")
      create(:record, artist: artist, title: "Abbey Road")
      create(:record, artist: artist, title: "Midnight Marauders")

      get "/records"

      expect(response.body.index("Abbey Road")).to be < response.body.index("Midnight Marauders")
      expect(response.body.index("Midnight Marauders")).to be < response.body.index("Zebra")
    end
  end

  describe "GET /records/:id" do
    it "shows the selected record" do
      artist = create(:artist, name: "A Tribe Called Quest")

      record = create(
        :record,
        artist: artist,
        title: "Midnight Marauders",
        release_year: 1993
      )

      get "/records/#{record.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Midnight Marauders")
      expect(response.body).to include("A Tribe Called Quest")
      expect(response.body).to include("1993")
    end
  end

  describe "GET /records/new" do
    it "shows the new record form" do
      get "/records/new"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /records" do
    it "creates a new record with valid information" do
      artist = create(:artist)

      expect {
        post "/records", params: {
          record: {
            title: "The Low End Theory",
            release_year: 1991,
            format: "LP",
            condition: "Near Mint",
            artist_id: artist.id
          }
        }
      }.to change(Record, :count).by(1)

      record = Record.last

      expect(record.title).to eq("The Low End Theory")
      expect(record.artist).to eq(artist)
      expect(response).to redirect_to(record_path(record))
    end

    it "does not create a record with invalid information" do
      artist = create(:artist)

      expect {
        post "/records", params: {
          record: {
            title: "",
            release_year: "",
            format: "",
            condition: "",
            artist_id: artist.id
          }
        }
      }.not_to change(Record, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title can&#39;t be blank")
    end
  end

  describe "GET /records/:id/edit" do
    it "shows the edit form for the selected record" do
      record = create(:record)

      get "/records/#{record.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(record.title)
    end
  end

  describe "PATCH /records/:id" do
    it "updates the selected record with valid information" do
      record = create(:record, title: "Old Title")

      patch "/records/#{record.id}", params: {
        record: {
          title: "New Title"
        }
      }

      record.reload

      expect(record.title).to eq("New Title")
      expect(response).to redirect_to(record_path(record))
    end

    it "does not update the record with invalid information" do
      record = create(:record, title: "Original Title")

      patch "/records/#{record.id}", params: {
        record: {
          title: ""
        }
      }

      record.reload

      expect(record.title).to eq("Original Title")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title can&#39;t be blank")
    end
  end

  describe "DELETE /records/:id" do
    it "deletes the selected record" do
      record = create(:record)

      expect {
        delete "/records/#{record.id}"
      }.to change(Record, :count).by(-1)

      expect(response).to redirect_to(records_path)
    end
  end
end
