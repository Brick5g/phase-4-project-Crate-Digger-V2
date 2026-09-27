class RecordGenresController < ApplicationController
  before_action :require_login
  before_action :set_record

  def new
    load_genre_options
  end

  def create
    @record.replace_genres!(
      primary_genre_id: params[:primary_genre_id],
      subgenre_ids: params[:subgenre_ids],
      new_genre_name: params[:new_genre_name]
    )

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    @error =
      error.record.errors.full_messages.join(", ")

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
      @record.primary_record_genre

    @additional_genre_ids =
      @record.additional_genre_ids
  end
end
