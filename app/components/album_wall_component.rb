# frozen_string_literal: true

class AlbumWallComponent < ViewComponent::Base
  def initialize(records:)
    @records = records
  end

  def records?
    @records.any?
  end

  def reversed_records
    @records.reverse
  end
end
