class User < ApplicationRecord
  has_secure_password

  has_many :collection_entries,
           dependent: :destroy

  has_many :records,
           through: :collection_entries

  has_many :reviews,
           dependent: :destroy

  validates :username,
            presence: true

  validates :email,
            presence: true,
            uniqueness: true

  def collection_entry_for(record)
    collection_entries.find_by(
      record: record
    )
  end

  def review_for(record)
    reviews.find_by(
      record: record
    )
  end

  def review_from(record)
    record.reviews.find do |review|
      review.user_id == id
    end
  end
end
