class RecordsController < ApplicationController
  def index
    @records = Record.alphabetical
  end

  def show
    @record = Record.find(params[:id])
  end

  def new
    @record = Record.new
    @artists = Artist.all
  end

  def create
    @record = Record.new(record_params)

    if @record.save
      redirect_to record_path(@record)
    else
      @artists = Artist.all
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @record = Record.find(params[:id])
    @artists = Artist.all
  end

  def update
    @record = Record.find(params[:id])

    if @record.update(record_params)
      redirect_to record_path(@record)
    else
      @artists = Artist.all
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @record = Record.find(params[:id])
    @record.destroy

    redirect_to records_path
  end

  private

  def record_params
    params.require(:record).permit(
      :title,
      :release_year,
      :format,
      :condition,
      :artist_id
    )
  end
end
