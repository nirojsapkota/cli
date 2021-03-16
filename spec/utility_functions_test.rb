require_relative '../utils/utility_functions'
require 'csv'
require 'webmock/rspec'
describe Utils::UtilityFunctions do
  let!(:dummy_class) { Class.new { include Utils::UtilityFunctions } }
  let!(:util_obj) { dummy_class.new }

  let!(:r_headers) do
    ['Email', 'First Name', 'Last Name', 'Residential Address Street', 'Residential Address Locality']
  end
  let!(:r_data) { ['', 'John', 'Doe', 'Abc', 'ARCTURUS'] }
  let!(:invalid_row) { CSV::Row.new(r_headers, r_data) }

  it 'should clean_data' do
    rs = util_obj.clean_data(invalid_row)
    expect(rs).to be_nil
  end

  it 'should return proper query obj' do
    q = util_obj.query_param('some_address')
    expect(q).to include(query: 'some_address')
  end

  let!(:invalid_data) { ['', 'John', 'Doe', 'Abc', 'def'] }
  it 'should validate postcode location combination' do
    r_headers << 'Residential Address Postcode'
    r_data << '4722'

    invalid_row = CSV::Row.new(r_headers, r_data)
    q = util_obj.valid_postcode_location(invalid_row)
    expect(q).to be true
  end

  it 'should invalidate postcode location combination' do
    r_headers << 'Residential Address Postcode'
    r_data << '4822'

    invalid_row = CSV::Row.new(r_headers, r_data)
    q = util_obj.valid_postcode_location(invalid_row)
    expect(q).to be false
  end

  it 'should validate geocode' do
    geo_response = {
      status: 'success',
      data: [{ 'latitude' => -20.272893, 'longitude' => 148.716829, 'type' => 'locality', 'name' => 'Airlie Beach',
               'number' => nil, 'postal_code' => nil, 'street' => nil, 'confidence' => 0.6, 'region' => 'Queensland', 'region_code' => 'QLD', 'county' => 'Whitsunday', 'locality' => 'Airlie Beach', 'administrative_area' => nil, 'neighbourhood' => nil, 'country' => 'Australia', 'country_code' => 'AUS', 'continent' => 'Oceania', 'label' => 'Airlie Beach, QLD, Australia' }]
    }
    stub_request(:any, 'http://api.positionstack.com/v1/forward?access_key=f96643d0d2f7ac1f26a8553f8ab2fc81&limit=1&query=Abc,ARCTURUS')
      .to_return(status: 200, body: geo_response.to_json)
    q = util_obj.geocode(invalid_row)
    expect(q).to eq({ 'latitude' => -20.272893, 'longitude' => 148.716829 })
  end

  it 'should return false for invalid geocode' do
    geo_response = {
      status: 'fail',
      data: []
    }
    stub_request(:any, 'http://api.positionstack.com/v1/forward?access_key=f96643d0d2f7ac1f26a8553f8ab2fc81&limit=1&query=Abc,ARCTURUS')
      .to_return(status: 400, body: geo_response.to_json)
    q = util_obj.geocode(invalid_row)
    expect(q).to be false
  end
end
