class RecordsController < ApplicationController
  before_action :require_login,
                only: [
                  :new,
                  :create,
                  :edit,
                  :update,
                  :destroy
                ]

  before_action :set_record,
                only: [
                  :show,
                  :edit,
                  :update,
                  :destroy
                ]

  def index
    @records = Record.alphabetical
  end

  def show
  end

  def new
    @record = Record.new
    load_form_options
  end

  def create
    @record = Record.new(
      record_params
    )

    load_form_options

    if duplicate_primary_genre?
      @genre_error =
        "The new genre cannot be the same as the primary genre."

      render :new,
             status: :unprocessable_content

      return
    end

    Record.transaction do
      @record.save!

      save_record_genres
    end

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    if error.record == @record
      @record = error.record
    else
      @genre_error =
        error.record.errors.full_messages.join(", ")
    end

    load_form_options

    render :new,
           status: :unprocessable_content
  end

  def edit
    load_form_options
  end

  def update
    load_form_options

    if duplicate_primary_genre?
      @genre_error =
        "The new genre cannot be the same as the primary genre."

      render :edit,
             status: :unprocessable_content

      return
    end

    Record.transaction do
      @record.update!(
        record_params
      )

      save_record_genres
    end

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    if error.record == @record
      @record = error.record
    else
      @genre_error =
        error.record.errors.full_messages.join(", ")
    end

    load_form_options

    render :edit,
           status: :unprocessable_content
  end

  def destroy
    @record.destroy

    redirect_to records_path
  end

  private

  def set_record
    @record = Record.find(
      params[:id]
    )
  end

  def record_params
    params.require(
      :record
    ).permit(
      :title,
      :artist_id,
      :release_date,
      :release_type,
      :description
    )
  end

  def load_form_options
    @artists = Artist.order(
      :name
    )

    @genres = Genre.order(
      :name
    )

    @primary_genre_id =
      if params[:primary_genre_id].present?
        params[:primary_genre_id].to_i
      elsif @record.persisted?
        @record.record_genres.find_by(
          primary_genre: true
        )&.genre_id
      end

    @additional_genre_ids =
      if params.key?(:subgenre_ids)
        Array(
          params[:subgenre_ids]
        ).reject(
          &:blank?
        ).map(
          &:to_i
        )
      elsif @record.persisted?
        @record.record_genres.where(
          primary_genre: false
        ).pluck(
          :genre_id
        )
      else
        []
      end
  end

  def selected_primary_genre
    return if params[:primary_genre_id].blank?

    Genre.find(
      params[:primary_genre_id]
    )
  end

  def selected_additional_genres
    ids = Array(
      params[:subgenre_ids]
    ).reject(
      &:blank?
    )

    Genre.where(
      id: ids
    )
  end

  def new_genre_name
    params[:new_genre_name].to_s.strip
  end

  def duplicate_primary_genre?
    primary_genre =
      selected_primary_genre

    return false if primary_genre.nil?
    return false if new_genre_name.blank?

    normalize_genre_name(
      primary_genre.name
    ) == normalize_genre_name(
      new_genre_name
    )
  end

  def find_or_create_new_genre
    return if new_genre_name.blank?

    existing_genre = Genre.all.find do |genre|
      normalize_genre_name(
        genre.name
      ) == normalize_genre_name(
        new_genre_name
      )
    end

    return existing_genre if existing_genre

    Genre.create!(
      name: new_genre_name.titleize,
      description: "Added by a Crate Digger user."
    )
  end

  def save_record_genres
    primary_genre =
      selected_primary_genre

    additional_genres =
      selected_additional_genres

    custom_genre =
      find_or_create_new_genre

    if primary_genre.nil? &&
       custom_genre.present?
      primary_genre = custom_genre
      custom_genre = nil
    end

    @record.record_genres.destroy_all

    if primary_genre.present?
      @record.record_genres.create!(
        genre: primary_genre,
        primary_genre: true
      )
    end

    additional_genres.each do |genre|
      next if genre == primary_genre

      @record.record_genres.create!(
        genre: genre,
        primary_genre: false
      )
    end

    if custom_genre.present? &&
       custom_genre != primary_genre &&
       !additional_genres.include?(custom_genre)
      @record.record_genres.create!(
        genre: custom_genre,
        primary_genre: false
      )
    end
  end

  def normalize_genre_name(name)
    name.to_s
        .downcase
        .tr("_-", "  ")
        .squish
  end
end
