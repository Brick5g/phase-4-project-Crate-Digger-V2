class CollectionEntriesController < ApplicationController
  before_action :require_login

  def index
    @collection_entries = current_user.collection_entries
  end

  def new
    @record = Record.find(params[:record_id])
    @collection_entry = current_user.collection_entries.new(record: @record)
  end

  def create
    @record = Record.find(params[:record_id])

    @collection_entry = current_user.collection_entries.new(
      collection_entry_params
    )

    @collection_entry.record = @record

    if @collection_entry.save
      redirect_to collection_entries_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @collection_entry = current_user.collection_entries.find(params[:id])
  end

  def update
    @collection_entry = current_user.collection_entries.find(params[:id])

    if @collection_entry.update(collection_entry_params)
      redirect_to collection_entries_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @collection_entry = current_user.collection_entries.find(params[:id])
    @collection_entry.destroy

    redirect_to collection_entries_path
  end

  private

  def collection_entry_params
    params.require(:collection_entry).permit(
      :purchase_price,
      :notes
    )
  end
end
