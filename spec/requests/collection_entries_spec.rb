require "rails_helper"

RSpec.describe "CollectionEntries", type: :request do
  describe "GET /collection_entries" do
    it "redirects logged out users to login" do
      get "/collection_entries"

      expect(response).to redirect_to(login_path)
    end

    it "allows logged in users to view their collection" do
      user = create(:user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      get "/collection_entries"

      expect(response).to have_http_status(:ok)
    end

    it "only shows collection entries that belong to the logged in user" do
      user = create(:user)
      other_user = create(:user)

      user_entry = create(
        :collection_entry,
        user: user,
        notes: "My personal record"
      )

      other_entry = create(
        :collection_entry,
        user: other_user,
        notes: "Someone else's record"
      )

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      get "/collection_entries"

      expect(response.body).to include(user_entry.notes)
      expect(response.body).not_to include(other_entry.notes)
    end
  end

  describe "GET /records/:record_id/collection_entries/new" do
    it "allows a logged in user to access the new collection entry page" do
      user = create(:user)
      record = create(:record)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      get "/records/#{record.id}/collection_entries/new"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /records/:record_id/collection_entries" do
    it "creates a collection entry for the logged in user" do
      user = create(:user)
      record = create(:record)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      expect do
        post "/records/#{record.id}/collection_entries", params: {
          collection_entry: {
            purchase_price: 25.00,
            notes: "Great copy"
          }
        }
      end.to change(CollectionEntry, :count).by(1)

      collection_entry = CollectionEntry.last

      expect(collection_entry.user).to eq(user)
      expect(collection_entry.record).to eq(record)
      expect(response).to redirect_to(collection_entries_path)
    end

    it "does not create a collection entry with invalid information" do
      user = create(:user)
      record = create(:record)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      expect do
        post "/records/#{record.id}/collection_entries", params: {
          collection_entry: {
            purchase_price: nil,
            notes: ""
          }
        }
      end.not_to change(CollectionEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Purchase price can&#39;t be blank")
      expect(response.body).to include("Notes can&#39;t be blank")
    end
  end

  describe "GET /collection_entries/:id/edit" do
    it "allows a logged in user to edit their own collection entry" do
      user = create(:user)
      collection_entry = create(:collection_entry, user: user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      get "/collection_entries/#{collection_entry.id}/edit"

      expect(response).to have_http_status(:ok)
    end

    it "does not allow a user to edit another user's collection entry" do
      user = create(:user)
      other_user = create(:user)
      other_entry = create(:collection_entry, user: other_user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      get "/collection_entries/#{other_entry.id}/edit"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /collection_entries/:id" do
    it "updates the logged in user's collection entry" do
      user = create(:user)

      collection_entry = create(
        :collection_entry,
        user: user,
        purchase_price: 20.00,
        notes: "Original notes"
      )

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      patch "/collection_entries/#{collection_entry.id}", params: {
        collection_entry: {
          purchase_price: 35.00,
          notes: "Updated notes"
        }
      }

      collection_entry.reload

      expect(collection_entry.purchase_price).to eq(35.00)
      expect(collection_entry.notes).to eq("Updated notes")
      expect(response).to redirect_to(collection_entries_path)
    end

    it "does not update a collection entry with invalid information" do
      user = create(:user)

      collection_entry = create(
        :collection_entry,
        user: user,
        purchase_price: 20.00,
        notes: "Original notes"
      )

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      patch "/collection_entries/#{collection_entry.id}", params: {
        collection_entry: {
          purchase_price: nil,
          notes: ""
        }
      }

      collection_entry.reload

      expect(collection_entry.purchase_price).to eq(20.00)
      expect(collection_entry.notes).to eq("Original notes")
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not allow a user to update another user's collection entry" do
      user = create(:user)
      other_user = create(:user)

      other_entry = create(
        :collection_entry,
        user: other_user,
        purchase_price: 20.00,
        notes: "Original notes"
      )

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      patch "/collection_entries/#{other_entry.id}", params: {
        collection_entry: {
          purchase_price: 100.00,
          notes: "Hacked notes"
        }
      }

      other_entry.reload

      expect(response).to have_http_status(:not_found)
      expect(other_entry.purchase_price).to eq(20.00)
      expect(other_entry.notes).to eq("Original notes")
    end
  end

  describe "DELETE /collection_entries/:id" do
    it "deletes the logged in user's collection entry" do
      user = create(:user)
      collection_entry = create(:collection_entry, user: user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      expect do
        delete "/collection_entries/#{collection_entry.id}"
      end.to change(CollectionEntry, :count).by(-1)

      expect(response).to redirect_to(collection_entries_path)
    end

    it "does not allow a user to delete another user's collection entry" do
      user = create(:user)
      other_user = create(:user)
      other_entry = create(:collection_entry, user: other_user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      expect do
        delete "/collection_entries/#{other_entry.id}"
      end.not_to change(CollectionEntry, :count)

      expect(response).to have_http_status(:not_found)
      expect(CollectionEntry.exists?(other_entry.id)).to be(true)
    end
  end
end
