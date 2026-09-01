class Genre < ApplicationRecord
  has_many :record_genres, dependent: :destroy
  has_many :records, through: :record_genres

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
