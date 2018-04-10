require 'portable_bridge_notation'
require 'pp'
module BridgeStats
  ## Build the joint empirical distribution
  class Builder
    def initialize
      file_name_prefix = '/Users/tim/BackedUpToMacMini/GTD/DIGITAL_REFERENCE/BRIDGE/20000_pbn_games/20000-'
      8.times do |file_num|
        file = File.open("#{file_name_prefix}#{file_num + 1}.pbn")
        importer = PortableBridgeNotation::Api::Importer.create(io: file)
        importer.import { |game| verify_ort_ddt_consistent(game) }
        pp "file #{file_num + 1} done"
      end
    end

    def verify_ort_ddt_consistent(game)
      opt_res_table = game.supplemental_sections[
          :OptimumResultTable].section_string.split(/\n/)
      dbl_dmy_tricks = game.supplemental_sections[
          :DoubleDummyTricks].tag_value.split(//)
      opt_res_table.each_with_index do |tbl_entry, index|
        next unless index > 0

        tricks_from_ort = tbl_entry.split(/\s+/)[2].to_i(10)
        tricks_from_ddt = dbl_dmy_tricks[index - 1].to_i(16)
        pp(dbl_dmy_tricks, opt_res_table) if (tricks_from_ort != tricks_from_ddt)
      end
    end
  end
end
