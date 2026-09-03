class AllowNotesToBeBlankOnRecordGenres < ActiveRecord::Migration[8.1]
  def change
    change_column_null :record_genres, :notes, true
  end
end
