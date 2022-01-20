begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'open-uri'
require_relative 'lib/swiss_holidays'

CSV_REFERENCE_URL = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSBIc0MVbjTEMhm4lqFsGAYnU3wFw5zwJkhMksi2M_3D49mUl836mu-Nel1XrkkL-nmTIMb8D_8GDuo/pub?gid=1983911977&single=true&output=csv'

namespace :swiss_holidays do
  desc "Updates swiss_holidays.json from ENV['CSV']"
  task :update_from_spreadsheet do
    require 'csv'
    require 'json'

    content = URI.open(CSV_REFERENCE_URL).read
    File.write('/tmp/swag2.csv', content)
    csv = CSV.parse(content, headers: true)

    public_holidays = {}
    regions = {}

    csv.each do |row|
      regions = {}

      id = row['id'].to_sym

      SwissHolidays::REGIONS.each do |region|
        letter = row[region.to_s.upcase]
        next unless letter && !letter.empty?

        is_standard = !letter.include?('*')
        is_full_day = letter.include?('1')
        is_half_day = letter.include?('0.5')

        raise "Unknown contents: #{letter}" if !is_full_day && !is_half_day

        regions[region] = {
          standard: is_standard,
          whole_day: is_full_day, # use 'whole_day' so false can mean multiple things in future (only one hour off etc.)
        }
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
