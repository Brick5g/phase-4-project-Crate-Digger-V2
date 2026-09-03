class User < ApplicationRecord
  has_secure_password

  has_many :collection_entries, dependent: :destroy
  has_many :records, through: :collection_entries

  has_many :reviews, dependent: :destroy

  validates :username, presence: true
  validates :email, presence: true, uniqueness: true
end
