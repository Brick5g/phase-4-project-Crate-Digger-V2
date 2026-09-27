class Artist < ApplicationRecord
  has_many :records,
           dependent: :destroy

  has_many :artist_genres,
           dependent: :destroy

  has_many :genres,
           through: :artist_genres

  validates :name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :musicbrainz_id,
            uniqueness: true,
            allow_blank: true

  def self.find_or_import_from_musicbrainz!(artist_data)
    musicbrainz_id =
      artist_data["id"]

    artist_name =
      artist_data["name"]

    raise "Artist name is missing" if artist_name.blank?

    artist =
      find_by_musicbrainz_id(
        musicbrainz_id
      )

    artist ||= find_by_normalized_name(
      artist_name
    )

    if artist.present?
      artist.update_from_musicbrainz!(
        artist_data
      )

      return artist
    end

    create!(
      name: artist_name,
      country: artist_data["country"],
      musicbrainz_id: musicbrainz_id
    )
  end

  def self.find_by_musicbrainz_id(musicbrainz_id)
    return if musicbrainz_id.blank?

    find_by(
      musicbrainz_id: musicbrainz_id
    )
  end

  def self.find_by_normalized_name(name)
    normalized_name =
      normalize_text(
        name
      )

    all.find do |artist|
      normalize_text(
        artist.name
      ) == normalized_name
    end
  end

  def self.normalize_text(text)
    text.to_s
        .tr("_", " ")
        .squish
        .downcase
  end

  def primary_artist_genre
    artist_genres.find_by(
      primary_genre: true
    )
  end

  def additional_artist_genres
    artist_genres.where(
    primary_genre: false
    )
  end

  def additional_genre_ids
    artist_genres.where(
      primary_genre: false
    ).pluck(
      :genre_id
    )
  end

  def update_from_musicbrainz!(artist_data)
    updates = {}

    if musicbrainz_id.blank? &&
       artist_data["id"].present?
      updates[:musicbrainz_id] =
        artist_data["id"]
    end

    api_name =
      artist_data["name"]

    if api_name.present? &&
       name != api_name
      updates[:name] =
        api_name
    end

    if country.blank? &&
       artist_data["country"].present?
      updates[:country] =
        artist_data["country"]
    end

    update!(
      updates
    ) if updates.any?
  end

  def update_with_genres!(
    artist_attributes,
    primary_genre_id:,
    subgenre_ids:,
    new_genre_name:
  )
    transaction do
      update!(
        artist_attributes
      )

      replace_genres!(
        primary_genre_id: primary_genre_id,
        subgenre_ids: subgenre_ids,
        new_genre_name: new_genre_name
      )
    end
  end

  def replace_genres!(
    primary_genre_id:,
    subgenre_ids:,
    new_genre_name:
  )
    primary_genre = find_genre(
      primary_genre_id
    )

    selected_subgenres = find_genres(
      subgenre_ids
    )

    cleaned_new_genre_name =
      new_genre_name.to_s.strip

    if duplicate_genre_name?(
      primary_genre,
      cleaned_new_genre_name
    )
      errors.add(
        :genres,
        "new genre cannot be the same as the primary genre"
      )

      raise ActiveRecord::RecordInvalid,
            self
    end

    new_genre =
      Genre.find_or_create_by_normalized_name!(
        cleaned_new_genre_name,
        description: "Added by a Crate Digger user."
      )

    if primary_genre.nil? &&
       new_genre.present?
      primary_genre = new_genre
      new_genre = nil
    end

    artist_genres.destroy_all

    if primary_genre.present?
      artist_genres.create!(
        genre: primary_genre,
        primary_genre: true
      )
    end

    selected_subgenres.each do |genre|
      next if genre == primary_genre

      artist_genres.create!(
        genre: genre,
        primary_genre: false
      )
    end

    if new_genre.present? &&
       new_genre != primary_genre &&
       !selected_subgenres.include?(new_genre)
      artist_genres.create!(
        genre: new_genre,
        primary_genre: false
      )
    end
  end

  private

  def find_genre(genre_id)
    return if genre_id.blank?

    Genre.find(
      genre_id
    )
  end

  def find_genres(genre_ids)
    ids = Array(
      genre_ids
    ).reject(
      &:blank?
    )

    Genre.where(
      id: ids
    )
  end

  def duplicate_genre_name?(
    primary_genre,
    new_genre_name
  )
    return false if primary_genre.nil?
    return false if new_genre_name.blank?

    Genre.normalize_name(
      primary_genre.name
    ) == Genre.normalize_name(
      new_genre_name
    )
  end
end
