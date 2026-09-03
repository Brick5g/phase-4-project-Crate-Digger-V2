class AddMusicMetadataToArtists < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :hometown, :string
    add_column :artists, :details, :text
    add_column :artists, :musicbrainz_id, :string
  end
end
