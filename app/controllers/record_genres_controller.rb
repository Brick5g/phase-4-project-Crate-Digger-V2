class RecordGenresController < ApplicationController
  before_action :require_login
  before_action :set_record

  def new
    load_genre_options
  end

  def create
    load_genre_options

    primary_genre = find_genre(
      params[:primary_genre_id]
    )

    selected_subgenres = find_genres(
      params[:subgenre_ids]
    )

    new_genre_name = params[:new_genre_name].to_s.strip

    new_genre = find_or_build_genre(
      new_genre_name
    )

    if duplicate_primary_genre?(
      primary_genre,
      new_genre_name
    )
      @error =
        "The new genre cannot be the same as the primary genre."

      render :new,
             status: :unprocessable_content

      return
    end

    if new_genre&.new_record? &&
       !new_genre.save
      @error =
        new_genre.errors.full_messages.join(", ")

      render :new,
             status: :unprocessable_content

      return
    end

    if primary_genre.nil? &&
       new_genre.present?
      primary_genre = new_genre
      new_genre = nil
    end

    save_record_genres(
      primary_genre,
      selected_subgenres,
      new_genre
    )

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    @error = error.record.errors.full_messages.join(", ")

    load_genre_options

    render :new,
           status: :unprocessable_content
  end

  def destroy
    record_genre = @record.record_genres.find(
      params[:id]
    )

    record_genre.destroy

    redirect_to record_path(
      @record
    )
  end

  private

  def set_record
    @record = Record.find(
      params[:record_id]
    )
  end

  def load_genre_options
    @genres = Genre.order(
      :name
    )

    @primary_record_genre =
      @record.record_genres.find_by(
        primary_genre: true
      )

    @additional_genre_ids =
      @record.record_genres.where(
        primary_genre: false
      ).pluck(
        :genre_id
      )
  end

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

  def find_or_build_genre(name)
    return if name.blank?

    existing_genre = Genre.all.find do |genre|
      normalize_genre_name(
        genre.name
      ) == normalize_genre_name(
        name
      )
    end

    return existing_genre if existing_genre

    Genre.new(
      name: name.titleize,
      description: "Added by a Crate Digger user."
    )
  end

  def duplicate_primary_genre?(primary_genre, new_genre_name)
    return false if primary_genre.nil?
    return false if new_genre_name.blank?

    normalize_genre_name(
      primary_genre.name
    ) == normalize_genre_name(
      new_genre_name
    )
  end

  def save_record_genres(
    primary_genre,
    selected_subgenres,
    new_genre
  )
    Record.transaction do
      @record.record_genres.destroy_all

      if primary_genre.present?
        @record.record_genres.create!(
          genre: primary_genre,
          primary_genre: true
        )
      end

      selected_subgenres.each do |genre|
        next if genre == primary_genre

        @record.record_genres.create!(
          genre: genre,
          primary_genre: false
        )
      end

      if new_genre.present? &&
         new_genre != primary_genre &&
         !selected_subgenres.include?(new_genre)
        @record.record_genres.create!(
          genre: new_genre,
          primary_genre: false
        )
      end
    end
  end

  def normalize_genre_name(name)
    name.to_s
        .downcase
        .tr("_-", "  ")
        .squish
  end
end
