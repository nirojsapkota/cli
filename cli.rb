#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require './file_handler'

# parse_options class
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
      opts.banner = 'Usage: ./command.rb client.csv'
      opts.separator ''
    end

    opt_parser.parse!(args)
    @options
  end
end

parse_option = ParseOptions.new
options = parse_option.parse(ARGV)
filehandler = FileHandler.new(options)
filehandler.parse_csv if options.inputFile && !options.inputFile.empty?
