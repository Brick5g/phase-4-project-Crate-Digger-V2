class RecordGenre < ApplicationRecord
  belongs_to :record
  belongs_to :genre

  validates :primary_genre, inclusion: { in: [ true, false ] }
  validates :notes, presence: true

  validates :genre_id, uniqueness: { scope: :record_id }
end
