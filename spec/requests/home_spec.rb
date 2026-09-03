require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns a successful response" do
      get "/"

      expect(response).to have_http_status(:ok)
    end

    it "shows public navigation when logged out" do
      get "/"

      expect(response.body).to include("Crate Digger V2")
      expect(response.body).to include("Log In")
      expect(response.body).to include("Sign Up")
      expect(response.body).to include("Browse Records")
      expect(response.body).to include("Browse Artists")

      expect(response.body).not_to include("My Collection")
      expect(response.body).not_to include("Log Out")
    end

    it "shows user navigation when logged in" do
      user = create(
        :user,
        username: "crate_digger",
        email: "crate@example.com",
        password: "password",
        password_confirmation: "password"
      )

      post "/login", params: {
        email: user.email,
        password: "password"
      }

      get "/"

      expect(response.body).to include("Welcome, crate_digger!")
      expect(response.body).to include("My Collection")
      expect(response.body).to include("Log Out")

      expect(response.body).not_to include("Sign Up")
    end
  end
end
