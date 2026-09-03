class ArtistGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :genre_id,
            uniqueness: {
              scope: :artist_id
            }

  validate :only_one_primary_genre

  private

  def only_one_primary_genre
    return unless primary_genre
    return unless artist_id

    existing_primary_genre = ArtistGenre.where(
      artist_id: artist_id,
      primary_genre: true
    ).where.not(id: id)

    if existing_primary_genre.exists?
      errors.add(
        :primary_genre,
        "has already been selected for this artist"
      )
    end
  end
end
