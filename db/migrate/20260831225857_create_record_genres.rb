class CreateRecordGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :record_genres do |t|
      t.boolean :primary_genre, null: false, default: false
      t.text :notes, null: false
      t.references :record, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end

    add_index :record_genres, [ :record_id, :genre_id ], unique: true
  end
end
