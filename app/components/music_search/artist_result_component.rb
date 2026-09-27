# frozen_string_literal: true

class MusicSearch::ArtistResultComponent < ViewComponent::Base
  def initialize(artist:)
    @artist = artist
  end

  def country
    @artist["country"]
  end

  def disambiguation
    @artist["disambiguation"]
  end

  def score
    @artist["score"]
  end
end
