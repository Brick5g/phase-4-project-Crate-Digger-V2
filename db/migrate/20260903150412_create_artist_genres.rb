class CreateArtistGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :artist_genres do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.boolean :primary_genre, null: false, default: false

      t.timestamps
    end

    add_index :artist_genres,
              [ :artist_id, :genre_id ],
              unique: true
  end
end
