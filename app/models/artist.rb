class Artist < ApplicationRecord
  has_many :records,
           dependent: :destroy

  has_many :artist_genres,
           dependent: :destroy

  has_many :genres,
           through: :artist_genres

  validates :name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :musicbrainz_id,
            uniqueness: true,
            allow_blank: true
end
