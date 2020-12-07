begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require_relative 'lib/swiss_holidays'

namespace :swiss_holidays do
  # CSV reference here: https://docs.google.com/spreadsheets/d/1JdpdYausYfIiB3f-PaRDKwvqijMhaqKQrO8rQ12puM8/edit?usp=sharing
  desc "Updates swiss_holidays.json from ENV['CSV']"
  task :update_from_spreadsheet do
    raise "Supply ENV['CSV'] csv file path" if ENV['CSV'].nil?

    require 'csv'
    require 'json'
    csv = CSV.parse(File.read(ENV['CSV']), headers: true)

    all_regions = {}
    public_holidays = {}
    regions = {}

    csv.each do |row|
      regions = {}

      id = row['id'].to_sym

      SwissHolidays::REGIONS.each do |region|
        letter = row[region.to_s.upcase]
        next unless letter && !letter.empty?

        letter = letter[0] # ignore footnotes/numbers

        is_standard = letter.match?(/[ABC]/)
        is_half_day = letter.match?(/[Cc]/)

        regions[region] = {
          standard: is_standard,
          whole_day: !is_half_day, # use 'whole_day' so false can mean multiple things in future (only one hour off etc.)
        }

        all_regions[region] = 1
      end

      public_holidays[id] = {
        labels: {
          de: row['label_de'],
          fr: row['label_fr'],
          en: row['label_en'],
          it: row['label_it'],
        },
        date: row['date'],
        regions: regions,
      }
    end

    # update data file
    path = File.join(File.dirname(__FILE__), 'data', 'swiss_holidays.json')
    File.write(path, JSON.pretty_generate(public_holidays))
  end
end
