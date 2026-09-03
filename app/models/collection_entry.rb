class CollectionEntry < ApplicationRecord
  belongs_to :user
  belongs_to :record

  validates :notes, presence: true

  validates :record_id,
            uniqueness: {
              scope: :user_id
            }
end
