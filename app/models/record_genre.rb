class RecordGenre < ApplicationRecord
  belongs_to :record
  belongs_to :genre

  validates :primary_genre,
            inclusion: { in: [ true, false ] }

  validates :notes, presence: true

  validates :genre_id,
            uniqueness: {
              scope: :record_id
            }

  validate :only_one_primary_genre

  private

  def only_one_primary_genre
    return unless primary_genre
    return unless record_id

    existing_primary_genre = RecordGenre.where(
      record_id: record_id,
      primary_genre: true
    ).where.not(id: id)

    if existing_primary_genre.exists?
      errors.add(
        :primary_genre,
        "has already been selected for this record"
      )
    end
  end
end
