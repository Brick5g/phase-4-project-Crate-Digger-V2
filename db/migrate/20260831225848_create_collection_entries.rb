class CreateCollectionEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_entries do |t|
      t.decimal :purchase_price, precision: 8, scale: 2, null: false
      t.text :notes, null: false
      t.references :user, null: false, foreign_key: true
      t.references :record, null: false, foreign_key: true

      t.timestamps
    end

    add_index :collection_entries, [ :user_id, :record_id ], unique: true
  end
end
