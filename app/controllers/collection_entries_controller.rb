class CollectionEntriesController < ApplicationController
  before_action :require_login

  before_action :set_record,
                only: [ :new, :create ]

  before_action :set_collection_entry,
                only: [ :edit, :update, :destroy ]

  def index
    @collection_entries =
      current_user.collection_entries.includes(
        record: [
          :artist,
          :reviews
        ]
      )
  end

  def new
    @collection_entry =
      current_user.collection_entries.new(
        record: @record
      )
  end

  def create
    @collection_entry =
      current_user.collection_entries.new(
        collection_entry_params
      )

    @collection_entry.record =
      @record

    if @collection_entry.save
      redirect_to collection_entries_path
    else
      render :new,
             status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @collection_entry.update(
      collection_entry_params
    )
      redirect_to collection_entries_path
    else
      render :edit,
             status: :unprocessable_content
    end
  end

  def destroy
    @collection_entry.destroy

    redirect_to collection_entries_path
  end

  private

  def set_record
    @record = Record.find(
      params[:record_id]
    )
  end

  def set_collection_entry
    @collection_entry =
      current_user.collection_entries.find(
        params[:id]
      )
  end

  def collection_entry_params
    params.require(
      :collection_entry
    ).permit(
      :notes
    )
  end
end
