class Record < ApplicationRecord
  belongs_to :artist

  has_many :collection_entries, dependent: :destroy
  has_many :users, through: :collection_entries

  has_many :record_genres, dependent: :destroy
  has_many :genres, through: :record_genres

  has_many :reviews, dependent: :destroy

  validates :title, presence: true
  validates :release_type, presence: true

  validates :musicbrainz_id,
            uniqueness: true,
            allow_blank: true

  scope :alphabetical, -> { order(:title) }
end
