# frozen_string_literal: true

class GenreTagComponent < ViewComponent::Base
  def initialize(record_genre:)
    @record_genre = record_genre
  end

  def primary?
    @record_genre.primary_genre?
  end
end
