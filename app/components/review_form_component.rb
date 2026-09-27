# frozen_string_literal: true

class ReviewFormComponent < ViewComponent::Base
  def initialize(review:, record:)
    @review = review
    @record = record
  end

  def new_review?
    @review.new_record?
  end

  def form_model
    if new_review?
      [ @record, @review ]
    else
      @review
    end
  end

  def submit_text
    if new_review?
      "Save My Review"
    else
      "Update My Review"
    end
  end
end
