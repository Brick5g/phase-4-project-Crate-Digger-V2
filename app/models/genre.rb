class Genre < ApplicationRecord
  has_many :record_genres, dependent: :destroy
  has_many :records, through: :record_genres

  has_many :artist_genres, dependent: :destroy
  has_many :artists, through: :artist_genres

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
