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
        importer.import {|game| build_distribution(game)}
        pp "file #{file_num + 1} done"
      end
    end

    def five_c_is_best?(best_minimal_contracts)
      best_minimal_contracts.include?('5c') && !best_minimal_contracts.include?('3nt')
    end

    def build_distribution(game)
      ddt = DoubleDummyTricks.new(game.supplemental_sections[
                                      :DoubleDummyTricks].tag_value)
      deal = Deal.new(game.deal)
      n_best_minimal_contracts = ddt.best_minimal_contracts(:n)
      s_best_minimal_contracts = ddt.best_minimal_contracts(:s)
      return unless five_c_is_best?(n_best_minimal_contracts) || five_c_is_best?(s_best_minimal_contracts)

      # pseudocode: if only one of n and s make 5c, they are declarer.
      # if both of n and s make 5c,
      #   if their club length is unequal
      #     whoever has longer clubs is declarer
      #   otherwise
      #     whoever has greater total points is declarer
      n_clubs_length = deal.hand(:n).suit_length(:c)
      s_clubs_length = deal.hand(:s).suit_length(:c)
      n_total_points = deal.total_partnership_points(:n, :c)
      s_total_points = deal.total_partnership_points(:s, :c)
      declarer = if five_c_is_best?(n_best_minimal_contracts) && !five_c_is_best?(s_best_minimal_contracts)
                   :n
                 elsif five_c_is_best?(s_best_minimal_contracts) && !five_c_is_best?(n_best_minimal_contracts)
                   :s
                 elsif n_clubs_length > s_clubs_length
                   :n
                 elsif s_clubs_length > n_clubs_length
                   :s
                 elsif n_total_points >= s_total_points
                   :n
                 else
                   :s
                 end
      total_points = deal.total_partnership_points(declarer, :c)
      voids = deal.blankleton_count 0, :ns
      singletons = deal.blankleton_count 1, :ns
      doubletons = deal.blankleton_count 2, :ns
      unstopped_suits = deal.unstopped_suit_count(:ns)
      sixplussers = (6..13).inject(0) {|c, n| c + deal.blankleton_count(n, :ns)}
      puts "#{game.board}\t#{deal.hcp(:ns)}\t#{total_points}\t" \
             "#{deal.fit(:ns, :c)}\t#{voids}\t#{singletons}\t#{doubletons}\t#{unstopped_suits}\t#{sixplussers}\n"
    end
  end
end
