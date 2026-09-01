class CollectionEntriesController < ApplicationController
  before_action :require_login

  def index
    @collection_entries = current_user.collection_entries
  end
end
