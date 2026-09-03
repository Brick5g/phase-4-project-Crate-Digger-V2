require "rails_helper"

RSpec.describe "CollectionEntries", type: :request do
  def log_in(user)
    post "/login", params: {
      email: user.email,
      password: "password"
    }
  end

  describe "GET /collection_entries" do
    it "redirects logged out users to login" do
      get "/collection_entries"

      expect(response).to redirect_to(login_path)
    end

    it "returns a successful response for a logged in user" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      log_in(user)

      get "/collection_entries"

      expect(response).to have_http_status(:ok)
    end

    it "shows only the logged in user's collection entries" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      other_user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      own_record = create(
        :record,
        title: "My Favorite Record"
      )

      other_record = create(
        :record,
        title: "Someone Else Record"
      )

      create(
        :collection_entry,
        user: user,
        record: own_record
      )

      create(
        :collection_entry,
        user: other_user,
        record: other_record
      )

      log_in(user)

      get "/collection_entries"

      expect(response.body).to include(
        "My Favorite Record"
      )

      expect(response.body).not_to include(
        "Someone Else Record"
      )
    end
  end

  describe "GET /records/:record_id/collection_entries/new" do
    it "shows the form to save a record for a logged in user" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(
        :record,
        title: "Midnight Marauders"
      )

      log_in(user)

      get "/records/#{record.id}/collection_entries/new"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Midnight Marauders"
      )

      expect(response.body).to include(
        "Save to My Collection"
      )
    end
  end

  describe "POST /records/:record_id/collection_entries" do
    it "saves a record to the logged in user's collection" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/collection_entries", params: {
          collection_entry: {
            notes: "One of my favorites."
          }
        }
      }.to change(CollectionEntry, :count).by(1)

      collection_entry = CollectionEntry.last

      expect(collection_entry.user).to eq(user)
      expect(collection_entry.record).to eq(record)

      expect(collection_entry.notes).to eq(
        "One of my favorites."
      )

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "allows a record to be saved without notes" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/collection_entries", params: {
          collection_entry: {
            notes: ""
          }
        }
      }.to change(CollectionEntry, :count).by(1)

      collection_entry = CollectionEntry.last

      expect(collection_entry.notes).to eq("")

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "does not allow the same release to be saved twice" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      create(
        :collection_entry,
        user: user,
        record: record
      )

      log_in(user)

      expect {
        post "/records/#{record.id}/collection_entries", params: {
          collection_entry: {
            notes: "Trying to save it twice"
          }
        }
      }.not_to change(CollectionEntry, :count)

      expect(response).to have_http_status(
        :unprocessable_content
      )
    end
  end

  describe "GET /collection_entries/:id/edit" do
    it "shows the edit form for the logged in user's entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      collection_entry = create(
        :collection_entry,
        user: user,
        notes: "Original notes"
      )

      log_in(user)

      get "/collection_entries/#{collection_entry.id}/edit"

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        "Original notes"
      )
    end

    it "does not allow a user to edit another user's entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      other_user = create(:user)

      other_entry = create(
        :collection_entry,
        user: other_user
      )

      log_in(user)

      get "/collection_entries/#{other_entry.id}/edit"

      expect(response).to have_http_status(
        :not_found
      )
    end
  end

  describe "PATCH /collection_entries/:id" do
    it "updates the logged in user's collection entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      collection_entry = create(
        :collection_entry,
        user: user,
        notes: "Original notes"
      )

      log_in(user)

      patch "/collection_entries/#{collection_entry.id}", params: {
        collection_entry: {
          notes: "Updated notes"
        }
      }

      collection_entry.reload

      expect(collection_entry.notes).to eq(
        "Updated notes"
      )

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "allows a user to clear their note" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      collection_entry = create(
        :collection_entry,
        user: user,
        notes: "Original notes"
      )

      log_in(user)

      patch "/collection_entries/#{collection_entry.id}", params: {
        collection_entry: {
          notes: ""
        }
      }

      collection_entry.reload

      expect(collection_entry.notes).to eq("")

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "does not allow a user to update another user's collection entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      other_user = create(:user)

      other_entry = create(
        :collection_entry,
        user: other_user,
        notes: "Original notes"
      )

      log_in(user)

      patch "/collection_entries/#{other_entry.id}", params: {
        collection_entry: {
          notes: "You should not see this"
        }
      }

      other_entry.reload

      expect(other_entry.notes).to eq(
        "Original notes"
      )

      expect(response).to have_http_status(
        :not_found
      )
    end
  end

  describe "DELETE /collection_entries/:id" do
    it "removes the logged in user's collection entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      collection_entry = create(
        :collection_entry,
        user: user
      )

      log_in(user)

      expect {
        delete "/collection_entries/#{collection_entry.id}"
      }.to change(CollectionEntry, :count).by(-1)

      expect(response).to redirect_to(
        collection_entries_path
      )
    end

    it "does not allow a user to delete another user's collection entry" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      other_user = create(:user)

      other_entry = create(
        :collection_entry,
        user: other_user
      )

      log_in(user)

      expect {
        delete "/collection_entries/#{other_entry.id}"
      }.not_to change(CollectionEntry, :count)

      expect(response).to have_http_status(
        :not_found
      )
    end
  end
end
