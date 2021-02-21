#!/usr/bin/env ruby
require 'csv'

require_relative 'Utils/UtilityFunctions'
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
      @error << exception
    end

    puts "Total number of data: #{@rows_processed}"
    puts "Valid data processed: #{@valid_rows_processed}"
  end

end
