require 'test/unit/assertions'
require 'csv'
include Test::Unit::Assertions
require 'webmock/rspec'
require_relative '../FileHandler'

describe FileHandler do
  let(:obj) { described_class.new(inputObj) }
  let(:inputObj) { double(inputFile: 'test.csv') }

  it 'properly initializes the file' do
    expect(obj.filename).to eq 'test.csv'
  end

  it 'validates the existence of file' do
    allow(inputObj).to receive(:inputFile) { 'nonexisting.csv' }
    expect(obj.filename).to eq 'nonexisting.csv'
  end

  it 'validate and filter out invalid rows' do
    allow(inputObj).to receive(:inputFile) { 'invalid.csv' }
    expect(obj.filename).to eq 'invalid.csv'
  end

  it 'parses valid csv' do
    geo_response = {
      status: 'success',
      data: [{ 'latitude' => -20.272893, 'longitude' => 148.716829, 'type' => 'locality', 'name' => 'Airlie Beach',
               'number' => nil, 'postal_code' => nil, 'street' => nil, 'confidence' => 0.6, 'region' => 'Queensland',
               'region_code' => 'QLD', 'county' => 'Whitsunday', 'locality' => 'Airlie Beach',
               'administrative_area' => nil,
               'neighbourhood' => nil, 'country' => 'Australia', 'country_code' => 'AUS', 'continent' => 'Oceania',
               'label' => 'Airlie Beach, QLD, Australia' }]
    }
    stub_request(:any, 'http://api.positionstack.com/v1/forward?access_key=f96643d0d2f7ac1f26a8553f8ab2fc81&limit=1&query=8540%20Charli%20Summit,AIRLIE%20BEACH')
      .to_return(status: 200, body: geo_response.to_json)

    allow(inputObj).to receive(:inputFile) { 'sample_test.csv' }
    obj.parse_csv
    expect(obj.invalid_rows).to eq 0
    expect(obj.valid_rows_processed).to eq 1
  end
end
