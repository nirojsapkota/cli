#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require "./FileHandler"

class ParseOptions
  #
  # Return a structure describing the @options.
  #
  def initialize
    @options = OpenStruct.new
  end

  def parse(args)
    @options.inputFile = args.first

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./command.rb client.csv"
      opts.separator ""
    end

    opt_parser.parse!(args)
    @options
  end

end

parseOption = ParseOptions.new
options = parseOption.parse(ARGV)
filehandler = FileHandler.new(options)
if options.inputFile && !options.inputFile.empty?
  filehandler.parse_csv
end



