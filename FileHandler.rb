#!/usr/bin/env ruby
require 'csv'
require 'uri'
require 'net/http'
require 'json'
require_relative 'utils/UtilityFunctions'
class FileHandler

  include Utils::UtilityFunctions

  attr_accessor :filename
  attr_accessor :error
  attr_accessor :valid_rows_processed
  attr_accessor :invalid_rows

  def initialize(options)
    @filename = options.inputFile
    @error = []
    @rows_processed = 0
    @valid_rows_processed = 0
    @invalid_rows = 0
  end

  def parse_csv
    begin
      file = File.open("./#{filename}", "r")

      CSV.foreach(file, headers: true, skip_blanks: true) do |row|
        if clean_data(row)
          if valid_postcode_location(row)
            # now geocode
            if geo_info = geocode(row)
              @valid_rows_processed+= 1
              row << geo_info
              p row.to_s
            else
              @invalid_rows +=1
            end
          else
            @invalid_rows +=1
          end
        else
          @invalid_rows +=1
        end
        @rows_processed+= 1
      end
    rescue => exception
      pp exception.message
      @error << exception
    end

    puts "Total number of data: #{@rows_processed}"
    puts "Valid data processed: #{@valid_rows_processed}"
  end

  # def clean_data(data)
  #   p data
  #   REQUIRED_KEYS.each do |r|
  #     return nil if (data[r].nil? || data[r].empty?)
  #   end
  # end

  # https://www.australiantownslist.com/
  # Used AU TOWNS SAMPLE .csv to validate postcode addresss
  # considering Residential Address to validate against postcode combination
  # def valid_postcode_location(data)
  #   csv = CSV.read("./utils/au-towns-sample.csv", headers: true)
  #   if csv.find { |row| row["postcode"] == data["Residential Address Postcode"] && row["name"].downcase == data["Residential Address Locality"].downcase }
  #     return true
  #   else
  #     return false
  #   end
  # end

  # def geocode(data)
  #   address = [data['Residential Address Street'], data['Residential Address Locality']].join(",")
  #   uri = URI(GEO_API_URL)
  #   uri.query = URI.encode_www_form(query_param(address))
  #   response = Net::HTTP.get_response(uri)
  #   if response.is_a?(Net::HTTPSuccess)
  #     result = JSON.parse(response.body)["data"]
  #     result ? result.first.select{ |k, _| KEYS_TO_GET.include?(k)} : false
  #   else
  #     false
  #   end
  # end

  # def query_param(address)
  #   {
  #     'access_key': GEO_API_KEY,
  #     'limit':  1,
  #     'query': address
  #   }
  # end

end
