class AllowCountryToBeBlankOnArtists < ActiveRecord::Migration[8.1]
  def change
    change_column_null :artists, :country, true
  end
end
