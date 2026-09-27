# frozen_string_literal: true

class CollectionCardComponent < ViewComponent::Base
  def initialize(entry:, review:)
    @entry = entry
    @record = entry.record
    @review = review
  end

  def reviewed?
    @review.present?
  end

  def artwork?
    @record.artwork_url.present?
  end

  def notes?
    @entry.notes.present?
  end
end
