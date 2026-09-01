require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns a successful response" do
      get "/login"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /login" do
    it "logs in a user with valid credentials" do
      user = create(
        :user,
        email: "collector@example.com",
        password: "password123"
      )

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      expect(response).to redirect_to(root_path)
    end

    it "does not log in a user with invalid credentials" do
      user = create(
        :user,
        email: "collector@example.com",
        password: "password123"
      )

      post "/login", params: {
        email: user.email,
        password: "wrongpassword"
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password")
    end
  end

  describe "DELETE /logout" do
    it "logs out the current user" do
      user = create(:user)

      post "/login", params: {
        email: user.email,
        password: "password123"
      }

      delete "/logout"

      expect(response).to redirect_to(login_path)
    end
  end
end
