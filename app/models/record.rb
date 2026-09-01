class Record < ApplicationRecord
  belongs_to :artist

  has_many :collection_entries, dependent: :destroy
  has_many :users, through: :collection_entries

  has_many :record_genres, dependent: :destroy
  has_many :genres, through: :record_genres

  validates :title, presence: true
  validates :release_year, presence: true
  validates :format, presence: true
  validates :condition, presence: true
end
