module Utils
  module UtilityFunctions
    require 'uri'
    require 'net/http'
    require 'json'
    REQUIRED_KEYS = ['Email', 'First Name', 'Last Name', 'Residential Address Street', 'Residential Address Locality'].freeze
    KEYS_TO_GET = %w[latitude longitude].freeze

    # https://positionstack.com/ used for geocode
    GEO_API_URL = 'http://api.positionstack.com/v1/forward'.freeze
    GEO_API_KEY = 'f96643d0d2f7ac1f26a8553f8ab2fc81'.freeze
    AU_DATA_FILE_PATH = File.join(File.dirname(__FILE__), 'au-towns-sample.csv').freeze

    def clean_data(data)
      REQUIRED_KEYS.each do |r|
        return nil if data[r].nil? || data[r].empty?
      end
    end

    # https://www.australiantownslist.com/
    # Used AU TOWNS SAMPLE .csv to validate postcode addresss
    # considering Residential Address to validate against postcode combination
    def valid_postcode_location(data)
      @csv ||= CSV.read(AU_DATA_FILE_PATH, headers: true)
      if @csv.find do |row|
           row['postcode'] == data['Residential Address Postcode'] && row['name'].downcase == data['Residential Address Locality'].downcase
         end
        true
      else
        false
      end
    end

    def geocode(data)
      address = [data['Residential Address Street'], data['Residential Address Locality']].join(',')
      uri = URI(GEO_API_URL)
      uri.query = URI.encode_www_form(query_param(address))
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)['data']
        result ? result.first.select { |k, _| KEYS_TO_GET.include?(k) } : false
      else
        false
      end
    end

    def query_param(address)
      {
        'access_key': GEO_API_KEY,
        'limit': 1,
        'query': address
      }
    end
  end
end
