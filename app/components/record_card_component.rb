# frozen_string_literal: true

class RecordCardComponent < ViewComponent::Base
  def initialize(record:)
    @record = record
  end

  def release_date
    @record.release_date || "Unknown"
  end
end
