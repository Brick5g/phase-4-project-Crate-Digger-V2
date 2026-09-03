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

    it "shows genre controls on the new release form" do
      log_in_user

      create(
        :genre,
        name: "Hip-Hop"
      )

      create(
        :genre,
        name: "R&B"
      )

      get "/records/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Primary Genre")
      expect(response.body).to include("Additional Genres")
      expect(response.body).to include("Genre Not Listed?")
      expect(response.body).to include("Hip-Hop")
      expect(response.body).to include("R&amp;B")
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
          },
          primary_genre_id: "",
          subgenre_ids: [],
          new_genre_name: ""
        }
      }.to change(
        Record,
        :count
      ).by(1)

      record = Record.last

      expect(record.title).to eq("The Low End Theory")
      expect(record.release_date).to eq(Date.new(1991, 9, 24))
      expect(record.release_type).to eq("Album")
      expect(record.description).to eq("A classic hip-hop album.")
      expect(record.artist).to eq(artist)

      expect(response).to redirect_to(
        record_path(record)
      )
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
          },
          primary_genre_id: "",
          subgenre_ids: [],
          new_genre_name: ""
        }
      }.not_to change(
        Record,
        :count
      )

      expect(response).to have_http_status(
        :unprocessable_content
      )

      expect(response.body).to include(
        "Title can&#39;t be blank"
      )

      expect(response.body).to include(
        "Release type can&#39;t be blank"
      )
    end

    it "creates a record with one primary genre" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records", params: {
        record: {
          title: "The Low End Theory",
          release_type: "Album",
          artist_id: artist.id
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [],
        new_genre_name: ""
      }

      record = Record.last

      record_genre =
        record.record_genres.find_by(
          genre: hip_hop
        )

      expect(record_genre).to be_present

      expect(
        record_genre.primary_genre
      ).to be(true)

      expect(response).to redirect_to(
        record_path(record)
      )
    end

    it "creates a record with multiple additional genres" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      jazz_rap = create(
        :genre,
        name: "Jazz Rap"
      )

      alternative_hip_hop = create(
        :genre,
        name: "Alternative Hip-Hop"
      )

      post "/records", params: {
        record: {
          title: "Midnight Marauders",
          release_type: "Album",
          artist_id: artist.id
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [
          jazz_rap.id,
          alternative_hip_hop.id
        ],
        new_genre_name: ""
      }

      record = Record.last

      primary_record_genre =
        record.record_genres.find_by(
          genre: hip_hop
        )

      additional_record_genres =
        record.record_genres.where(
          primary_genre: false
        )

      expect(
        primary_record_genre.primary_genre
      ).to be(true)

      expect(
        additional_record_genres.map(&:genre)
      ).to contain_exactly(
        jazz_rap,
        alternative_hip_hop
      )
    end

    it "creates a missing genre as an additional genre" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records", params: {
          record: {
            title: "New Release",
            release_type: "Album",
            artist_id: artist.id
          },
          primary_genre_id: hip_hop.id,
          subgenre_ids: [],
          new_genre_name: "Neo Soul"
        }
      }.to change(
        Genre,
        :count
      ).by(1)

      record = Record.last

      neo_soul = Genre.find_by(
        name: "Neo Soul"
      )

      expect(neo_soul).to be_present

      record_genre =
        record.record_genres.find_by(
          genre: neo_soul
        )

      expect(record_genre).to be_present

      expect(
        record_genre.primary_genre
      ).to be(false)
    end

    it "uses a new genre as the primary genre when no primary genre was selected" do
      log_in_user

      artist = create(:artist)

      post "/records", params: {
        record: {
          title: "New Release",
          release_type: "Album",
          artist_id: artist.id
        },
        primary_genre_id: "",
        subgenre_ids: [],
        new_genre_name: "Neo Soul"
      }

      record = Record.last

      neo_soul = Genre.find_by(
        name: "Neo Soul"
      )

      primary_record_genre =
        record.record_genres.find_by(
          primary_genre: true
        )

      expect(neo_soul).to be_present

      expect(
        primary_record_genre.genre
      ).to eq(
        neo_soul
      )
    end

    it "reuses an existing genre when the custom genre has different formatting" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records", params: {
          record: {
            title: "New Release",
            release_type: "Album",
            artist_id: artist.id
          },
          primary_genre_id: "",
          subgenre_ids: [],
          new_genre_name: "hip_hop"
        }
      }.not_to change(
        Genre,
        :count
      )

      record = Record.last

      expect(
        record.genres
      ).to include(
        hip_hop
      )

      expect(
        record.record_genres.find_by(
          genre: hip_hop
        ).primary_genre
      ).to be(true)
    end

    it "does not duplicate a primary genre that was also selected as an additional genre" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      post "/records", params: {
        record: {
          title: "New Release",
          release_type: "Album",
          artist_id: artist.id
        },
        primary_genre_id: hip_hop.id,
        subgenre_ids: [
          hip_hop.id
        ],
        new_genre_name: ""
      }

      record = Record.last

      expect(
        record.record_genres.where(
          genre: hip_hop
        ).count
      ).to eq(1)

      expect(
        record.record_genres.find_by(
          genre: hip_hop
        ).primary_genre
      ).to be(true)
    end

    it "rejects typing the same genre as the selected primary genre" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records", params: {
          record: {
            title: "New Release",
            release_type: "Album",
            artist_id: artist.id
          },
          primary_genre_id: hip_hop.id,
          subgenre_ids: [],
          new_genre_name: "hip hop"
        }
      }.not_to change(
        Record,
        :count
      )

      expect(response).to have_http_status(
        :unprocessable_content
      )

      expect(response.body).to include(
        "cannot be the same as the primary genre"
      )
    end

    it "does not create a custom genre when the record itself is invalid" do
      log_in_user

      artist = create(:artist)

      expect {
        post "/records", params: {
          record: {
            title: "",
            release_type: "",
            artist_id: artist.id
          },
          primary_genre_id: "",
          subgenre_ids: [],
          new_genre_name: "Future Funk"
        }
      }.not_to change(
        Genre,
        :count
      )

      expect(
        Genre.find_by(
          name: "Future Funk"
        )
      ).to be_nil

      expect(response).to have_http_status(
        :unprocessable_content
      )
    end

    it "does not create genre associations when the record itself is invalid" do
      log_in_user

      artist = create(:artist)

      hip_hop = create(
        :genre,
        name: "Hip-Hop"
      )

      expect {
        post "/records", params: {
          record: {
            title: "",
            release_type: "",
            artist_id: artist.id
          },
          primary_genre_id: hip_hop.id,
          subgenre_ids: [],
          new_genre_name: ""
        }
      }.not_to change(
        RecordGenre,
        :count
      )

      expect(response).to have_http_status(
        :unprocessable_content
      )
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
      expect(record.release_date).to eq(
        Date.new(2026, 8, 1)
      )

      expect(response).to redirect_to(
        record_path(record)
      )
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

      expect(record.title).to eq(
        "Original Title"
      )

      expect(response).to have_http_status(
        :unprocessable_content
      )

      expect(response.body).to include(
        "Title can&#39;t be blank"
      )
    end
  end

  describe "DELETE /records/:id" do
    it "deletes the selected record for a logged in user" do
      log_in_user

      record = create(:record)

      expect {
        delete "/records/#{record.id}"
      }.to change(
        Record,
        :count
      ).by(-1)

      expect(response).to redirect_to(
        records_path
      )
    end
  end
end
