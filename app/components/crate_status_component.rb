# frozen_string_literal: true

class CrateStatusComponent < ViewComponent::Base
  def initialize(record:, current_user:)
    @record = record
    @current_user = current_user
  end

  def logged_in?
    @current_user.present?
  end

  def saved?
    collection_entry.present?
  end

  private

  def collection_entry
    return unless logged_in?

    @collection_entry ||=
      @current_user.collection_entry_for(
        @record
      )
  end
end
