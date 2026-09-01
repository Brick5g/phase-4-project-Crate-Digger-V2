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
end
