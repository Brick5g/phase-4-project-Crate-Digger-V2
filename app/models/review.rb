class Review < ApplicationRecord
  belongs_to :user
  belongs_to :record

  validates :rating,
            presence: true,
            inclusion: { in: 1..10 }

  validates :record_id,
            uniqueness: {
              scope: :user_id,
              message: "has already been reviewed by you"
            }
end
