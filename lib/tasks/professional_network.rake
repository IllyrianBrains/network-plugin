# frozen_string_literal: true

namespace :professional_network do
  desc "Import or update canonical cities from CSV"
  task import_cities: :environment do
    path = ENV.fetch("CSV")
    website_key = ENV.fetch("WEBSITE_KEY", "default")
    result = ProfessionalNetwork::CityImporter.new(path: path, website_key: website_key).import!
    puts "City import complete: #{result[:created]} created, #{result[:updated]} updated"
  end
end
