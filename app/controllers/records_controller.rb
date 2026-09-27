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

  before_action :load_form_options,
                only: [
                  :new,
                  :create,
                  :edit,
                  :update
                ]

  def index
    @records = Record.alphabetical
  end

  def show
  end

  def new
    @record = Record.new
  end

  def create
    @record = Record.new(
      record_params
    )

    @record.save_with_genres!(
      primary_genre_id: params[:primary_genre_id],
      subgenre_ids: params[:subgenre_ids],
      new_genre_name: params[:new_genre_name]
    )

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    handle_record_error(
      error
    )

    load_form_options

    render :new,
           status: :unprocessable_content
  end

  def edit
  end

  def update
    @record.update_with_genres!(
      record_params,
      primary_genre_id: params[:primary_genre_id],
      subgenre_ids: params[:subgenre_ids],
      new_genre_name: params[:new_genre_name]
    )

    redirect_to record_path(
      @record
    )
  rescue ActiveRecord::RecordInvalid => error
    handle_record_error(
      error
    )

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
      elsif @record&.persisted?
        @record.primary_record_genre&.genre_id
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
      elsif @record&.persisted?
        @record.additional_genre_ids
      else
        []
      end
  end

  def handle_record_error(error)
    if error.record == @record
      @record = error.record

      if @record.errors[:genres].any?
        @genre_error =
          @record.errors[:genres].join(", ")
      end
    else
      @genre_error =
        error.record.errors.full_messages.join(", ")
    end
  end
end
