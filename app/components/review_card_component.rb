# frozen_string_literal: true

class ReviewCardComponent < ViewComponent::Base
  def initialize(review:, current_user:)
    @review = review
    @current_user = current_user
  end

  def owned_by_current_user?
    @current_user == @review.user
  end
end
