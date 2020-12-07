require 'spec_helper'
require 'awesome_print'

describe SwissHolidays do
  let(:start_date) {  Date.civil(2019, 1, 1) }
  let(:end_date) { Date.civil(2019, 12, 31) }
  let(:region) { :zh }
  let(:locale) { nil }

  subject { SwissHolidays.between(start_date, end_date, region, locale) }

  it 'returns the correct holidays' do
    expect(subject).to eq [
      {
        id: :neujahrstag,
        label: 'Neujahrstag',
        date: Date.civil(2019, 1, 1),
        standard: true,
        whole_day: true,
      },
      {
        id: :berchtoldstag,
        label: 'Berchtoldstag',
        date: Date.civil(2019, 1, 2),
        standard: false,
        whole_day: true,
      },
      {
        id: :sechselaeuten,
        label: 'Sechseläuten',
        date: Date.civil(2019, 4, 8),
        standard: false,
        whole_day: false,
      },
      {
        id: :karfreitag,
        label: 'Karfreitag',
        date: Date.civil(2019, 4, 19),
        standard: true,
        whole_day: true,
      },
      {
        id: :ostern,
        label: 'Ostern',
        date: Date.civil(2019, 4, 21),
        standard: true,
        whole_day: true,
      },
      {
        id: :ostermontag,
        label: 'Ostermontag',
        date: Date.civil(2019, 4, 22),
        standard: true,
        whole_day: true,
      },
      {
        id: :tag_der_arbeit,
        label: 'Tag der Arbeit',
        date: Date.civil(2019, 5, 1),
        standard: true,
        whole_day: true,
      },
      {
        id: :auffahrt,
        label: 'Auffahrt',
        date: Date.civil(2019, 5, 30),
        standard: true,
        whole_day: true,
      },
      {
        id: :pfingsten,
        label: 'Pfingsten',
        date: Date.civil(2019, 6, 9),
        standard: true,
        whole_day: true,
      },
      {
        id: :pfingstmontag,
        label: 'Pfingstmontag',
        date: Date.civil(2019, 6, 10),
        standard: true,
        whole_day: true,
      },
      {
        id: :schweizer_bundesfeier,
        label: 'Schweizer Bundesfeier',
        date: Date.civil(2019, 8, 1),
        standard: true,
        whole_day: true,
      },
      {
        id: :knabenschiessen,
        label: 'Knabenschiessen',
        date: Date.civil(2019, 9, 9),
        standard: false,
        whole_day: false,
      },
      {
        id: :eidg_bettag,
        label: 'Eidg. Dank-, Buss- und Bettag',
        date: Date.civil(2019, 9, 15),
        standard: true,
        whole_day: true,
      },
      {
        id: :weihnachten,
        label: 'Weihnachten',
        date: Date.civil(2019, 12, 25),
        standard: true,
        whole_day: true,
      },
      {
        id: :stephanstag,
        label: 'Stephanstag',
        date: Date.civil(2019, 12, 26),
        standard: true,
        whole_day: true,
      },
    ]
  end

  describe 'params' do
    describe 'region' do
      context 'symbol' do
        let(:region) { :zh }
        specify { expect(subject.count).to eq 15 }
      end

      context 'string' do
        let(:region) { 'zh' }
        specify { expect(subject.count).to eq 15 }
      end
    end

    describe 'dates' do
      context 'date' do
        let(:start_date) { Date.civil(2020, 1, 1) }
        let(:end_date) { Date.civil(2020, 12, 31) }
        specify { expect(subject.count).to eq 15 }
      end

      context 'string' do
        let(:start_date) { '2020-01-01' }
        let(:end_date) { '2020-12-31' }
        specify { expect(subject.count).to eq 15 }
      end
    end
  end

  describe 'date ranges' do
    context 'multiple years' do
      let(:start_date) { Date.civil(2019, 1, 1) }
      let(:end_date) { Date.civil(2020, 12, 31) }

      specify do
        expect(subject).to include(
          id: :ostermontag,
          label: 'Ostermontag',
          date: Date.civil(2019, 4, 22),
          standard: true,
          whole_day: true,
        )

        expect(subject).to include(
          id: :ostermontag,
          label: 'Ostermontag',
          date: Date.civil(2020, 4, 13),
          standard: true,
          whole_day: true,
        )
      end
    end

    context 'partial' do
      let(:start_date) { Date.civil(2019, 12, 26) }
      let(:end_date) { Date.civil(2020, 1, 1) }

      specify do
        expect(subject).to eq [
          {
            id: :stephanstag,
            label: 'Stephanstag',
            date: Date.civil(2019, 12, 26),
            standard: true,
            whole_day: true,
          },
          {
            id: :neujahrstag,
            label: 'Neujahrstag',
            date: Date.civil(2020, 1, 1),
            standard: true,
            whole_day: true,
          },
        ]
      end
    end
  end

  describe 'locale support' do
    context do
      let(:locale) { 'en' }
      specify { expect(subject.first[:label]).to eq "New Year's Day" }
    end

    context 'with suffix' do
      let(:locale) { :'de-CH' }
      specify { expect(subject.first[:label]).to eq 'Neujahrstag' }
    end

    context 'not existing' do
      let(:locale) { 'ru' }
      specify { expect(subject.first[:label]).to eq 'Neujahrstag' }
    end

    context 'with i18n' do
      before do
        i18n = double('I18n')
        allow(i18n).to receive(:locale).and_return(locale)
        stub_const('I18n', i18n)
      end
    end
  end

  describe 'special case: labour day' do
    context do
      let(:region) { 'so' }
      it 'is standard but half day in SO' do
        expect(subject).to include(
          id: :tag_der_arbeit,
          label: 'Tag der Arbeit',
          date: Date.civil(2019, 5, 1),
          standard: true,
          whole_day: false,
        )
      end
    end

    context do
      let(:region) { 'fr' }
      it 'is not standard and half day in FR' do
        expect(subject).to include(
          id: :tag_der_arbeit,
          label: 'Tag der Arbeit',
          date: Date.civil(2019, 5, 1),
          standard: false,
          whole_day: false,
        )
      end
    end
  end

  describe 'sechseläuten' do
    let(:region) { :zh }

    it 'returns the correct values for the (known) dates of Sechseläuten' do
      # https://www.sechselaeuten.ch/assets/downloads/2020/Zuk%C3%BCnftige%20Daten/Sechselaeutendaten_2017-2025.pdf
      dates = 2021.upto(2025).collect { |year| SwissHolidays.send(:date_of_sechselaeuten, year) }
      expect(dates).to eq [
        Date.civil(2021, 4, 19),
        Date.civil(2022, 4, 25),
        Date.civil(2023, 4, 17),
        Date.civil(2024, 4, 15),
        Date.civil(2025, 4, 28),
      ]
    end
  end

end
