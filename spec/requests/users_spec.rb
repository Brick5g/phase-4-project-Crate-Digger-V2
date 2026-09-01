require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "returns a successful response" do
      get "/signup"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /signup" do
    it "creates a new user with valid information" do
      expect do
        post "/signup", params: {
          user: {
            username: "crate_digger",
            email: "collector@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it "does not create a user with invalid information" do
      expect do
        post "/signup", params: {
          user: {
          username: "",
          email: "",
          password: "password123",
          password_confirmation: "password123"
          }
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Username can&#39;t be blank")
      expect(response.body).to include("Email can&#39;t be blank")
    end
  end
end
