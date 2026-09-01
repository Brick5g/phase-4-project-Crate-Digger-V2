require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with a username, email, and password" do
      user = build(:user)

      expect(user).to be_valid
    end

    it "is invalid without a username" do
      user = build(:user, username: nil)

      expect(user).not_to be_valid
    end

    it "is invalid without an email" do
      user = build(:user, email: nil)

      expect(user).not_to be_valid
    end

    it "does not allow duplicate emails" do
      create(:user, email: "collector@example.com")
      duplicate_user = build(:user, email: "collector@example.com")

      expect(duplicate_user).not_to be_valid
    end
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      user = create(:user, password: "password123")

      expect(user.authenticate("password123")).to eq(user)
    end

    it "does not authenticate with the wrong password" do
      user = create(:user, password: "password123")

      expect(user.authenticate("wrongpassword")).to be_falsey
    end
  end
end
