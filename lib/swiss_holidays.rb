require 'date'
require 'json'

module SwissHolidays
  REGIONS = %i(zh be lu ur sz ow nw gl zg fr so bs bl sh ar ai sg gr ag tg ti vd vs ne ge ju)

  class UnknownRegionError < StandardError; end

  class << self
    def between(start_date, end_date, region, locale = i18n_locale)
      region = region.to_sym
      locale = locale&.to_sym

      raise UnknownRegionError unless REGIONS.include?(region)
      start_date = start_date.kind_of?(Date) ? start_date : Date.parse(start_date)
      end_date = end_date.kind_of?(Date) ? end_date : Date.parse(end_date)

      start_date.year.upto(end_date.year).collect do |year|
        generate_swiss_holidays_for_year(year, region, locale).select do |swiss_holiday|
          swiss_holiday[:date] >= start_date && swiss_holiday[:date] <= end_date
        end
      end.flatten.sort_by { |x| x[:date] }
    end

    private

    def generate_swiss_holidays_for_year(year, region, locale)
      swiss_holidays.collect do |id, swiss_holiday|
        date = case
               when swiss_holiday[:date] == '*'
                 send(:"date_of_#{id}", year)
               else
                 Date.parse("#{swiss_holiday[:date]}.#{year}")
               end

        regional_info = swiss_holiday[:regions][region]
        next unless regional_info && !regional_info.empty?

        label = swiss_holiday[:labels][locale] || swiss_holiday[:labels].values.first

        {
          id: id,
          label: label,
          date: date,
        }.merge(regional_info)
      end.compact
    end

    def i18n_locale
      defined?(I18n) && I18n.locale[0...2]
    end

    def swiss_holidays
      @swiss_holidays ||= JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'data', 'swiss_holidays.json')), symbolize_names: true)
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
      nth_weekday Date.civil(year, 9, 1), :sunday, nth: 3
    end

    def date_of_sechselaeuten(year)
      # at least good until 2025 (matches with official data)
      month = Date.civil(year, 4, 1)
      third = nth_weekday(month, :monday, nth: 3)
      second = nth_weekday(month, :monday, nth: 2)
      fourth = nth_weekday(month, :monday, nth: 4)

      return fourth if third == date_of_ostermontag(year) # monday after easter sunday?
      return second if third == beginning_of_week(date_of_ostersonntag(year)) # monday before easter sunday?
      third
    end

    def date_of_naefelser_fahrt(year)
      date = nth_weekday(Date.civil(year, 4, 1), :thursday, nth: 1)
      date += 7 if date == date_of_karfreitag(year) - 1 # gründonnerstag? then +1 week
      date
    end

    def date_of_genfer_bettag(year)
      first_sunday = nth_weekday(Date.civil(year, 9, 1), :sunday, nth: 1)
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
        begin
          date += 1
        end while week_ways[date.wday] != weekday
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
      date
    end

  end # class << self
end # SwissHolidays
