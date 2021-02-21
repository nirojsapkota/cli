require_relative '../Utils/UtilityFunctions'
require 'csv'
describe Utils::UtilityFunctions do

  let!(:dummy_class) { Class.new { include Utils::UtilityFunctions } }
  let!(:some_obj) { dummy_class.new }

  let!(:r_headers) {["Email", "First Name", "Last Name", "Residential Address Street", "Residential Address Locality"]}
  let!(:r_data) {['', 'John', 'Doe', 'Abc', 'ARCTURUS']}
  let!(:invalidRow) {CSV::Row.new(r_headers, r_data)}

  it 'should clean_data' do
    rs = some_obj.clean_data(invalidRow)
    expect(rs).to be_nil
  end

  it 'should return proper query obj' do
    q = some_obj.query_param("some_address")
    expect(q).to include(query: 'some_address')
  end

  let!(:invalid_data) {['', 'John', 'Doe', 'Abc', 'def']}
  it 'should validate postcode location combination' do
    r_headers << 'Residential Address Postcode'
    r_data << '4722'

    invalidRow = CSV::Row.new(r_headers, r_data)
    q = some_obj.valid_postcode_location(invalidRow)
    expect(q).to be true
  end

  it 'should invalidate postcode location combination' do
    r_headers << 'Residential Address Postcode'
    r_data << '4822'

    invalidRow = CSV::Row.new(r_headers, r_data)
    q = some_obj.valid_postcode_location(invalidRow)
    expect(q).to be false
  end


end
