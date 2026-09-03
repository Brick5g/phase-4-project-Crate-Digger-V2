class AllowNotesToBeBlankOnCollectionEntries < ActiveRecord::Migration[8.1]
  def change
    change_column_null :collection_entries, :notes, true
  end
end
