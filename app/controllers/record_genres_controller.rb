class RecordGenresController < ApplicationController
  before_action :require_login

  def new
    @record = Record.find(params[:record_id])
    @record_genre = @record.record_genres.new
    @genres = Genre.order(:name)
  end

  def create
    @record = Record.find(params[:record_id])

    @record_genre = @record.record_genres.new(
      record_genre_params
    )

    if @record_genre.save
      redirect_to record_path(@record)
    else
      @genres = Genre.order(:name)
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @record_genre = RecordGenre.find(params[:id])
    @record = @record_genre.record

    @record_genre.destroy

    redirect_to record_path(@record)
  end

  private

  def record_genre_params
    params.require(:record_genre).permit(
      :genre_id,
      :primary_genre,
      :notes
    )
  end
end
