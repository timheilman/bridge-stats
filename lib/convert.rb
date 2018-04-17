#!/usr/bin/ruby
require_relative 'bridge_stats/pbn_to_marshal_converter'
module BridgeStats
  # script to convert .pbn files to .rbmarshal files in the same directory
  PbnToMarshalConverter.new.convert(ARGV)
end