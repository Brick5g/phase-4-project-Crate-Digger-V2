require "rails_helper"

RSpec.describe "Reviews", type: :request do
  def log_in(user)
    post "/login", params: {
      email: user.email,
      password: "password"
    }
  end

  describe "GET /records/:record_id/reviews/new" do
    it "redirects a logged out user to login" do
      record = create(:record)

      get "/records/#{record.id}/reviews/new"

      expect(response).to redirect_to(login_path)
    end

    it "shows the review form to a logged in user" do
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

      get "/records/#{record.id}/reviews/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Review Midnight Marauders")
      expect(response.body).to include("Your Rating")
      expect(response.body).to include("Your Thoughts (Optional)")
    end
  end

  describe "POST /records/:record_id/reviews" do
    it "creates a review belonging to the logged in user and record" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/reviews", params: {
          review: {
            rating: 9,
            body: "Fantastic record."
          }
        }
      }.to change(Review, :count).by(1)

      review = Review.last

      expect(review.user).to eq(user)
      expect(review.record).to eq(record)
      expect(review.rating).to eq(9)
      expect(review.body).to eq("Fantastic record.")

      expect(response).to redirect_to(record_path(record))
    end

    it "allows a review without written thoughts" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/reviews", params: {
          review: {
            rating: 8,
            body: ""
          }
        }
      }.to change(Review, :count).by(1)

      review = Review.last

      expect(review.rating).to eq(8)
      expect(review.body).to eq("")
    end

    it "does not create a review with a rating below 1" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/reviews", params: {
          review: {
            rating: 0,
            body: ""
          }
        }
      }.not_to change(Review, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not create a review with a rating above 10" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      log_in(user)

      expect {
        post "/records/#{record.id}/reviews", params: {
          review: {
            rating: 11,
            body: ""
          }
        }
      }.not_to change(Review, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not allow the same user to review the same record twice" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      record = create(:record)

      create(
        :review,
        user: user,
        record: record
      )

      log_in(user)

      expect {
        post "/records/#{record.id}/reviews", params: {
          review: {
            rating: 7,
            body: "Another review."
          }
        }
      }.not_to change(Review, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /reviews/:id/edit" do
    it "shows the edit form to the review owner" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: user,
        rating: 8
      )

      log_in(user)

      get "/reviews/#{review.id}/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit My Review")
    end

    it "does not allow another user to edit the review" do
      owner = create(:user)

      other_user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: owner
      )

      log_in(other_user)

      get "/reviews/#{review.id}/edit"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /reviews/:id" do
    it "updates the review owner's review" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: user,
        rating: 7,
        body: "Original thoughts."
      )

      log_in(user)

      patch "/reviews/#{review.id}", params: {
        review: {
          rating: 10,
          body: "Even better after another listen."
        }
      }

      review.reload

      expect(review.rating).to eq(10)
      expect(review.body).to eq("Even better after another listen.")

      expect(response).to redirect_to(record_path(review.record))
    end

    it "does not update a review to an invalid rating" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: user,
        rating: 8
      )

      log_in(user)

      patch "/reviews/#{review.id}", params: {
        review: {
          rating: 15
        }
      }

      review.reload

      expect(review.rating).to eq(8)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not allow another user to update the review" do
      owner = create(:user)

      other_user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: owner,
        rating: 8
      )

      log_in(other_user)

      patch "/reviews/#{review.id}", params: {
        review: {
          rating: 1
        }
      }

      review.reload

      expect(review.rating).to eq(8)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /reviews/:id" do
    it "allows the review owner to delete the review" do
      user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: user
      )

      log_in(user)

      expect {
        delete "/reviews/#{review.id}"
      }.to change(Review, :count).by(-1)

      expect(response).to redirect_to(record_path(review.record))
    end

    it "does not allow another user to delete the review" do
      owner = create(:user)

      other_user = create(
        :user,
        password: "password",
        password_confirmation: "password"
      )

      review = create(
        :review,
        user: owner
      )

      log_in(other_user)

      expect {
        delete "/reviews/#{review.id}"
      }.not_to change(Review, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
