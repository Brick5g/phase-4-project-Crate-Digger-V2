class Record < ApplicationRecord
  belongs_to :artist

  has_many :collection_entries,
           dependent: :destroy

  has_many :users,
           through: :collection_entries

  has_many :record_genres,
           dependent: :destroy

  has_many :genres,
           through: :record_genres

  has_many :reviews,
           dependent: :destroy

  validates :title,
            presence: true

  validates :release_type,
            presence: true

  validates :musicbrainz_id,
            uniqueness: true,
            allow_blank: true

  scope :alphabetical,
        -> { order(:title) }

  def self.find_or_import_from_musicbrainz!(
    release_data,
    artist
  )
    musicbrainz_id =
      release_data["id"]

    record =
      find_by_musicbrainz_id(
        musicbrainz_id
      )

    record ||= find_by_normalized_title(
      release_data["title"],
      artist
    )

    if record.present?
      record.update_from_musicbrainz!(
        release_data
      )

      return record
    end

    create!(
      title: release_data["title"],
      artist: artist,
      release_date: complete_release_date(
        release_data["first-release-date"]
      ),
      release_type: release_data["primary-type"].presence || "Other",
      musicbrainz_id: musicbrainz_id,
      artwork_url: artwork_url(
        musicbrainz_id
      )
    )
  end

  def self.find_by_musicbrainz_id(musicbrainz_id)
    return if musicbrainz_id.blank?

    find_by(
      musicbrainz_id: musicbrainz_id
    )
  end

  def self.find_by_normalized_title(title, artist)
    return if title.blank?

    normalized_title =
      normalize_text(
        title
      )

    artist.records.find do |record|
      normalize_text(
        record.title
      ) == normalized_title
    end
  end

  def self.normalize_text(text)
    text.to_s
        .tr("_", " ")
        .squish
        .downcase
  end

  def self.complete_release_date(date_string)
    return if date_string.blank?

    return unless date_string.match?(
      /\A\d{4}-\d{2}-\d{2}\z/
    )

    Date.parse(
      date_string
    )
  end

  def self.artwork_url(release_id)
    return if release_id.blank?

    "https://coverartarchive.org/release-group/#{release_id}/front-500"
  end

  def primary_record_genre
    record_genres.find_by(
      primary_genre: true
    )
  end

  def additional_genre_ids
    record_genres.where(
      primary_genre: false
    ).pluck(
      :genre_id
    )
  end

  def update_from_musicbrainz!(release_data)
    updates = {}

    if musicbrainz_id.blank? &&
       release_data["id"].present?
      updates[:musicbrainz_id] =
        release_data["id"]
    end

    if release_data["title"].present?
      updates[:title] =
        release_data["title"]
    end

    if release_data["primary-type"].present?
      updates[:release_type] =
        release_data["primary-type"]
    end

    complete_date =
      self.class.complete_release_date(
        release_data["first-release-date"]
      )

    if complete_date.present?
      updates[:release_date] =
        complete_date
    end

    if release_data["id"].present?
      updates[:artwork_url] =
        self.class.artwork_url(
          release_data["id"]
        )
    end

    update!(
      updates
    ) if updates.any?
  end

  def import_musicbrainz_genres!(release_data)
    genre_data =
      release_data.fetch(
        "genres",
        []
      )

    genre_data.each do |genre_information|
      genre_name =
        genre_information["name"].to_s.strip

      next if genre_name.blank?

      genre =
        Genre.find_or_create_by_normalized_name!(
          genre_name,
          description: "Imported from MusicBrainz."
        )

      record_genres.find_or_create_by!(
        genre: genre
      ) do |record_genre|
        record_genre.primary_genre = false
      end
    end
  end

  def save_with_genres!(
    primary_genre_id:,
    subgenre_ids:,
    new_genre_name:
  )
    transaction do
      save!

      replace_genres!(
        primary_genre_id: primary_genre_id,
        subgenre_ids: subgenre_ids,
        new_genre_name: new_genre_name
      )
    end
  end

  def update_with_genres!(
    record_attributes,
    primary_genre_id:,
    subgenre_ids:,
    new_genre_name:
  )
    transaction do
      update!(
        record_attributes
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
    primary_genre =
      find_genre(
        primary_genre_id
      )

    additional_genres =
      find_genres(
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
        "The new genre cannot be the same as the primary genre."
      )

      raise ActiveRecord::RecordInvalid,
            self
    end

    custom_genre =
      Genre.find_or_create_by_normalized_name!(
        cleaned_new_genre_name,
        description: "Added by a Crate Digger user."
      )

    if primary_genre.nil? &&
       custom_genre.present?
      primary_genre = custom_genre
      custom_genre = nil
    end

    record_genres.destroy_all

    if primary_genre.present?
      record_genres.create!(
        genre: primary_genre,
        primary_genre: true
      )
    end

    additional_genres.each do |genre|
      next if genre == primary_genre

      record_genres.create!(
        genre: genre,
        primary_genre: false
      )
    end

    if custom_genre.present? &&
       custom_genre != primary_genre &&
       !additional_genres.include?(custom_genre)
      record_genres.create!(
        genre: custom_genre,
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
    ids =
      Array(
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
