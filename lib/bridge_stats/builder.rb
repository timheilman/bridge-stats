require 'portable_bridge_notation'
require 'pp'
module BridgeStats
  ## Build the joint empirical distribution
  class Builder
    attr_reader :player_satisfying
    attr_reader :partner_satisfying
    attr_accessor :deal
    attr_accessor :ddt
    attr_accessor :game

    def initialize
      @player_satisfying = Hash.new { |h, k| h[k] = [] }
      @partner_satisfying = Hash.new { |h, k| h[k] = [] }
      file_name_prefix = '/Users/tim/BackedUpToMacMini/GTD/DIGITAL_REFERENCE/BRIDGE/20000_pbn_games/20000-'
      puts "board\tsuit\tpoint count dir\thcp\ttotal points\t" \
             "fit\tspade fit\theart fit\teach partner is balanced?\tunstopped suits\tplayer best minimal contracts\t" \
             "partner best minimal contracts\n"
      8.times do |file_num|
        file = File.open("#{file_name_prefix}#{file_num + 1}.pbn")
        importer = PortableBridgeNotation::Api::Importer.create(io: file)
        importer.import {|game| build_distribution(game)}
        # pp "file #{file_num + 1} done"
      end
      puts "\n\n\nPlayer (N or E) Satisfying Boards:"
      print_sat_boards player_satisfying
      puts "\n\n\nPartner (S or W) Satisfying Boards:"
      print_sat_boards partner_satisfying
    end

    def build_distribution(game)
      self.game = game
      self.ddt = DoubleDummyTricks.new(game.supplemental_sections[
                                           :DoubleDummyTricks].tag_value)
      self.deal = Deal.new(game.deal)
      hypothesize(:e, :w, :c)
      hypothesize(:e, :w, :d)
      hypothesize(:n, :s, :c)
      hypothesize(:n, :s, :d)
    end

    def print_sat_boards whom
      puts "count\tproportion\tbest minimal contract(s)\n"
      total = whom.values.inject(0) { |ttl, list_of_boards| ttl + list_of_boards.length }
      whom.sort_by { |_k, v| v.length }.reverse.each do |contracts, list_of_boards|
        puts "#{list_of_boards.length}\t#{'%0.3f' % (list_of_boards.length / total.to_f)}\t#{contracts}\n"
      end
    end

    def hypothesize(player, partner, suit)
      player_length = deal.hand(player).suit_length(suit)
      partner_length = deal.hand(partner).suit_length(suit)
      fit = player_length + partner_length
      return unless fit >= 9
      spade_fit = deal.hand(player).suit_length(:s) + deal.hand(partner).suit_length(:s)
      return unless spade_fit < 8
      heart_fit = deal.hand(player).suit_length(:h) + deal.hand(partner).suit_length(:h)
      return unless heart_fit < 8
      point_count_dir = if player_length > partner_length
                          player
                        elsif partner_length > player_length
                          partner
                        elsif deal.total_partnership_points(player, suit) > deal.total_partnership_points(partner, suit)
                          player
                        else
                          partner
                        end
      total_points = deal.total_partnership_points(point_count_dir, suit)
      return unless total_points >= 23
      return unless total_points <= 29
      partnership_balanced = deal.hand(player).balanced && deal.hand(partner).balanced
      return if partnership_balanced
      partnership = player == :n ? :ns : :ew
      unstopped_suits = deal.unstopped_suit_count(partnership)
      return unless unstopped_suits > 0

      player_best_minimal_contracts = ddt.best_minimal_contracts(player).to_a.sort.join(',')
      partner_best_minimal_contracts = ddt.best_minimal_contracts(partner).to_a.sort.join(',')
      puts "#{game.board}\t#{suit}\t#{point_count_dir}\t#{deal.hcp(partnership)}\t#{total_points}\t" \
             "#{fit}\t#{spade_fit}\t#{heart_fit}\t#{partnership_balanced}\t#{unstopped_suits}\t#{player_best_minimal_contracts}\t" \
             "#{partner_best_minimal_contracts}\n"
      player_satisfying[player_best_minimal_contracts] << "#{game.board}_#{point_count_dir}_#{suit}"
      partner_satisfying[partner_best_minimal_contracts] << "#{game.board}_#{point_count_dir}_#{suit}"
    end
  end
end
