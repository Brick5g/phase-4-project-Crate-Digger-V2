class Artist < ApplicationRecord
  has_many :records, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :country, presence: true

  validates :musicbrainz_id,
            uniqueness: true,
            allow_blank: true
end
