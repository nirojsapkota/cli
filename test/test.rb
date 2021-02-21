require "test/unit/assertions"
require "csv"
include Test::Unit::Assertions
require_relative "../FileHandler"

describe FileHandler do
  let(:obj) { described_class.new(inputObj) }
  let(:inputObj) { double(inputFile: 'test.csv') }

  it 'properly initializes the file' do
    expect(obj.filename).to eq 'test.csv'
  end

  it 'validates the existence of file' do
    allow(inputObj).to receive(:inputFile) { 'nonexisting.csv' }
    expect(obj.filename).to eq 'nonexisting.csv'
    obj.parse_csv
    expect(obj.error).not_to be_empty
  end


  it 'validate and filter out invalid rows' do
    allow(inputObj).to receive(:inputFile) { 'invalid.csv' }
    expect(obj.filename).to eq 'invalid.csv'
    obj.parse_csv
    expect(obj.invalid_rows).to eq 1
    expect(obj.valid_rows_processed).to eq 0
  end
end
