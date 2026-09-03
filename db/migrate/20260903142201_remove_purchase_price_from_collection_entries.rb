class RemovePurchasePriceFromCollectionEntries < ActiveRecord::Migration[8.1]
  def change
    remove_column :collection_entries, :purchase_price, :decimal
  end
end
