require 'date'
require 'json'

module SwissHolidays
  REGIONS = %i(zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge ju)

  class << self
    def generate(start_date:, end_date:, region:)
      region = region.to_sym
      start_date = start_date.to_date
      end_date = end_date.to_date

      start_date.year.upto(end_date.year).collect do |year|
        yearly_public_holidays_for(year: year, region: region).select do |public_holiday|
          public_holiday[:date] >= start_date && public_holiday[:date] <= end_date
        end
      end.flatten
    end

    def yearly_public_holidays_for(year:, region:)
      region = region.to_sym
      year = year.to_i

      public_holidays.collect do |id, public_holiday|
        date = case
               when public_holiday[:date] == '*'
                 send(:"date_of_#{id}", year)
               else
                 Date.parse("#{public_holiday[:date]}.#{year}")
               end

        regional_info = public_holiday[:regions][region]
        next unless regional_info && !regional_info.empty?

        label = public_holiday[:labels][locale] || public_holiday[:labels].first

        {
          id: id,
          label: label,
          date: date,
        }.merge(regional_info)
      end.compact
    end

    def locale
      (defined?(I18n) ? I18n.locale[0...2] : 'de').to_sym
    end

    private

    def public_holidays
      @public_holidays ||= JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'data', 'swiss_holidays.json')), symbolize_names: true)
    end

    def date_of_karfreitag(year)
      date_of_ostern(year) - 2
    end

    def date_of_ostersonntag(year)
      date_of_ostern(year)
    end

    def date_of_ostermontag(year)
      date_of_ostern(year) + 1
    end

    def date_of_auffahrt(year)
      date_of_ostern(year) + 39
    end

    def date_of_pfingsten(year)
      date_of_ostern(year) + 49
    end

    def date_of_pfingstmontag(year)
      date_of_ostern(year) + 50
    end

    def date_of_fronleichnam(year)
      date_of_ostern(year) + 60
    end

    def date_of_eidg_bettag(year)
      nth_weekday Date.new(year, 9, 1), :sunday, nth: 3
    end

    def date_of_sechselaeuten(year)
      # at least good until 2025 (matches with official data)
      month = Date.new(year, 4, 1)
      third = nth_weekday(month, :monday, nth: 3)
      second = nth_weekday(month, :monday, nth: 2)
      fourth = nth_weekday(month, :monday, nth: 4)

      return fourth if third == date_of_ostermontag(year) # monday after easter sunday?
      return second if third == beginning_of_week(date_of_ostersonntag(year)) # monday before easter sunday?
      third
    end

    def date_of_naefelser_fahrt(year)
      date = nth_weekday(Date.new(year, 4, 1), :thursday, nth: 1)
      date += 7 if date == date_of_karfreitag(year) - 1 # gründonnerstag? then +1 week
      date
    end

    def date_of_genfer_bettag(year)
      first_sunday = nth_weekday(Date.new(year, 9, 1), :sunday, nth: 1)
      first_sunday + 4
    end

    def date_of_knabenschiessen(year)
      date_of_eidg_bettag(year) - 6 # monday before bettag
    end

    def date_of_bettagsmontag(year)
      date_of_eidg_bettag(year) + 1
    end

    def nth_weekday(date, weekday, nth:)
      week_ways = %i(sunday monday tuesday wednesday thursday friday saturday) # 0-6, Sunday is zero

      date = date - 1 # make sure we exclude potential first weekday so it counts
      nth.times do
        date += 1 while week_ways[date.wday] != weekday
      end
      date
    end

    # https://github.com/holidays/holidays/blob/f1de843dd2126337e201e03e384b0d10d4795a7a/lib/holidays/date_calculator/easter.rb#L5
    def date_of_ostern(year)
      g = year % 19 + 1
      s = (year - 1600) / 100 - (year - 1600) / 400
      l = (((year - 1400) / 100) * 8) / 25

      p_2 = (3 - 11 * g + s - l) % 30
      if p_2 == 29 || (p_2 == 28 && g > 11)
        p = p_2 - 1
      else
        p = p_2
      end

      d= (year + year / 4 - year / 100 + year / 400) % 7
      d_2 = (8 - d) % 7

      p_3 = (80 + p) % 7
      x_2 = d_2 - p_3

      x = (x_2 - 1) % 7 + 1
      e = p+x

      if e < 11
        Date.civil(year,3,e + 21)
      else
        Date.civil(year,4,e - 10)
      end
    end

    def beginning_of_week(date)
      date -= 1 while date.wday != 1
    end

  end # class << self
end # SwissHolidays
