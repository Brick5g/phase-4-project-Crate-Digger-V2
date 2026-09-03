class AddMusicMetadataToRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :records, :release_date, :date
    add_column :records, :release_type, :string
    add_column :records, :artwork_url, :string
    add_column :records, :musicbrainz_id, :string
    add_column :records, :description, :text
  end
end
