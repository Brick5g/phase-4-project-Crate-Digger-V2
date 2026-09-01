class CreateRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :records do |t|
      t.string :title, null: false
      t.integer :release_year, null: false
      t.string :format, null: false
      t.string :condition, null: false
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
