class ArtistsController < ApplicationController
  before_action :require_login,
                only: [
                  :new,
                  :create,
                  :edit,
                  :update,
                  :destroy
                ]

  before_action :set_artist,
                only: [
                  :show,
                  :edit,
                  :update,
                  :destroy
                ]

  def index
    @artists = Artist.order(
      :name
    )
  end

  def show
  end

  def new
    @artist = Artist.new
  end

  def create
    @artist = Artist.new(
      artist_params
    )

    if @artist.save
      redirect_to artist_path(
        @artist
      )
    else
      render :new,
             status: :unprocessable_content
    end
  end

  def edit
    load_genre_options
  end

  def update
    load_genre_options

    if @artist.update(
      artist_params
    )
      update_artist_genres

      redirect_to artist_path(
        @artist
      )
    else
      render :edit,
             status: :unprocessable_content
    end
  rescue ActiveRecord::RecordInvalid => error
    @genre_error =
      error.record.errors.full_messages.join(", ")

    load_genre_options

    render :edit,
           status: :unprocessable_content
  end

  def destroy
    @artist.destroy

    redirect_to artists_path
  end

  private

  def set_artist
    @artist = Artist.find(
      params[:id]
    )
  end

  def artist_params
    params.require(
      :artist
    ).permit(
      :name,
      :country,
      :hometown,
      :details
    )
  end

  def load_genre_options
    @genres = Genre.order(
      :name
    )

    @primary_artist_genre =
      @artist.artist_genres.find_by(
        primary_genre: true
      )

    @additional_genre_ids =
      @artist.artist_genres.where(
        primary_genre: false
      ).pluck(
        :genre_id
      )
  end

  def update_artist_genres
    primary_genre = find_genre(
      params[:primary_genre_id]
    )

    selected_subgenres = find_genres(
      params[:subgenre_ids]
    )

    new_genre_name =
      params[:new_genre_name].to_s.strip

    if duplicate_primary_genre?(
      primary_genre,
      new_genre_name
    )
      @genre_error =
        "The new genre cannot be the same as the primary genre."

      raise ActiveRecord::RecordInvalid.new(
        @artist
      )
    end

    new_genre = find_or_create_genre(
      new_genre_name
    )

    if primary_genre.nil? &&
       new_genre.present?
      primary_genre = new_genre
      new_genre = nil
    end

    Artist.transaction do
      @artist.artist_genres.destroy_all

      if primary_genre.present?
        @artist.artist_genres.create!(
          genre: primary_genre,
          primary_genre: true
        )
      end

      selected_subgenres.each do |genre|
        next if genre == primary_genre

        @artist.artist_genres.create!(
          genre: genre,
          primary_genre: false
        )
      end

      if new_genre.present? &&
         new_genre != primary_genre &&
         !selected_subgenres.include?(new_genre)
        @artist.artist_genres.create!(
          genre: new_genre,
          primary_genre: false
        )
      end
    end
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

  def find_or_create_genre(name)
    return if name.blank?

    existing_genre = Genre.all.find do |genre|
      normalize_genre_name(
        genre.name
      ) == normalize_genre_name(
        name
      )
    end

    return existing_genre if existing_genre

    Genre.create!(
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

  def normalize_genre_name(name)
    name.to_s
        .downcase
        .tr("_-", "  ")
        .squish
  end
end
