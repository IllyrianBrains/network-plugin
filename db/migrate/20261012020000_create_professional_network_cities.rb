# frozen_string_literal: true
class CreateProfessionalNetworkCities < ActiveRecord::Migration[7.0]
  def change
    create_table :professional_network_cities do |t|
      t.string :website_key, null: false, default: "default"
      t.string :name, null: false
      t.string :slug, null: false
      t.string :country
      t.decimal :lat, precision: 9, scale: 6
      t.decimal :lng, precision: 9, scale: 6
      t.string :status, null: false, default: "active"
      t.string :image_url
      t.string :luma_url
      t.string :instagram_url
      t.string :activities, array: true, null: false, default: []
      t.string :region
      t.string :region_color
      # Alternate spellings/exonyms (e.g. "Rome" for "Roma") so a free-text
      # member "city" field can be matched to this record.
      t.string :aliases, array: true, null: false, default: []
      t.timestamps
    end
    add_index :professional_network_cities, %i[website_key slug], unique: true
    add_index :professional_network_cities, %i[website_key status]
  end
end
