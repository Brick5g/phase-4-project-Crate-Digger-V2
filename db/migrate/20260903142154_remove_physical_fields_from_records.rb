class RemovePhysicalFieldsFromRecords < ActiveRecord::Migration[8.1]
  def change
    remove_column :records, :release_year, :integer
    remove_column :records, :format, :string
    remove_column :records, :condition, :string
  end
end
