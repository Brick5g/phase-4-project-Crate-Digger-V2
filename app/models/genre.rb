class Genre < ApplicationRecord
  has_many :record_genres,
           dependent: :destroy

  has_many :records,
           through: :record_genres

  has_many :artist_genres,
           dependent: :destroy

  has_many :artists,
           through: :artist_genres

  validates :name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  def self.normalize_name(name)
    name.to_s
        .downcase
        .gsub(/[^a-z0-9]+/, "")
  end

  def self.find_by_normalized_name(name)
    normalized_name = normalize_name(name)

    return if normalized_name.blank?

    all.find do |genre|
      normalize_name(genre.name) == normalized_name
    end
  end

  def self.find_or_create_by_normalized_name!(
    name,
    description: nil
  )
    cleaned_name = name.to_s.strip

    return if cleaned_name.blank?

    existing_genre =
      find_by_normalized_name(cleaned_name)

    return existing_genre if existing_genre.present?

    create!(
      name: cleaned_name,
      description: description
    )
  end
end
