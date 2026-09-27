class ArtistsController < ApplicationController
  before_action :require_login,
                except: [ :index, :show ]

  before_action :set_artist,
                only: [ :show, :edit, :update, :destroy ]

  before_action :load_genre_options,
                only: [ :new, :create, :edit, :update ]

  def index
    @artists = Artist.order(:name)
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

    if @artist.valid?
      begin
        @artist.transaction do
          @artist.save!

          @artist.replace_genres!(
            primary_genre_id: params[:primary_genre_id],
            subgenre_ids: params[:subgenre_ids],
            new_genre_name: params[:new_genre_name]
          )
        end

        redirect_to @artist,
                    notice: "Artist created successfully."
      rescue ActiveRecord::RecordInvalid
        render :new,
               status: :unprocessable_entity
      end
    else
      render :new,
             status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @artist.update_with_genres!(
      artist_params,
      primary_genre_id: params[:primary_genre_id],
      subgenre_ids: params[:subgenre_ids],
      new_genre_name: params[:new_genre_name]
    )

    redirect_to @artist,
                notice: "Artist updated successfully."
  rescue ActiveRecord::RecordInvalid
    render :edit,
           status: :unprocessable_entity
  end

  def destroy
    @artist.destroy

    redirect_to artists_path,
                notice: "Artist deleted successfully."
  end

  private

  def set_artist
    @artist = Artist.find(
      params[:id]
    )
  end

  def load_genre_options
    @genres = Genre.order(:name)

    return unless @artist&.persisted?

    @primary_artist_genre =
      @artist.primary_artist_genre

    @additional_genre_ids =
      @artist.additional_genre_ids
  end

  def artist_params
    params.require(:artist).permit(
      :name,
      :country,
      :hometown,
      :bio,
      :musicbrainz_id
    )
  end
end
