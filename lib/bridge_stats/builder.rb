require 'portable_bridge_notation'
require 'pp'
module BridgeStats
  ## Build the joint empirical distribution
  class Builder
    attr_reader :player_satisfying
    attr_reader :partner_satisfying
    attr_reader :count_writer
    attr_accessor :deal
    attr_accessor :ddt
    attr_accessor :game
    attr_accessor :matching_boards

    def initialize
      @player_satisfying = Hash.new {|h, k| h[k] = 0}
      @partner_satisfying = Hash.new {|h, k| h[k] = 0}
      @matching_boards = ""
      count_readers = []
      pids = []
      file_name_prefix = '/Users/tim/BackedUpToMacMini/GTD/DIGITAL_REFERENCE/BRIDGE/20000_pbn_games/fourways-20000-'
      puts "board\tsuit\tpoint count dir\thcp\ttotal points\t" \
             "fit\tspade fit\theart fit\teach partner is balanced?\tunstopped suits\tplayer best minimal contracts\t" \
             "partner best minimal contracts\n"
      4.times do |file_num|
        count_reader, @count_writer = IO.pipe
        count_readers << count_reader
        # outfile = File.new("#{file_name_prefix}#{file_num +1}.rbbinary", "w")
        pids << fork do
          count_reader.close
          file = File.open("#{file_name_prefix}#{file_num + 1}.rbbinary")
          PortableBridgeNotation::Api::Importer.create(io: file)
          # importer.import {|game| build_distribution(game)}
          # importer.import {|game| Marshal.dump(game, outfile)}
          # outfile.close()
          until (file.eof?) do
            build_distribution(Marshal.load(file))
          end
          exit!(0)
        end
        count_writer.close
      end
      pids.each {|pid| Process.wait2(pid)}
      count_readers.each do |count_reader|
        while message = count_reader.gets
          result = message.chomp.split(';')
          puts result[0]
          player_satisfying[result[1]] += 1
          partner_satisfying[result[2]] += 1
        end
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
      total = whom.values.inject(0) {|ttl, count_of_boards| ttl + count_of_boards}
      individual_chance_of_bestness = Hash.new {|h, k| h[k] = 0}
      whom.sort_by {|_k, v| v}.reverse.each do |contracts, count_of_boards|
        set_proportion = count_of_boards / total.to_f
        puts "#{count_of_boards}\t#{'%0.3f' % set_proportion}\t#{contracts}\n"
        contracts.split(',').each {|i| individual_chance_of_bestness[i] += set_proportion}
      end
      puts "\nindividual contract\tchance it is a best minimal contract"
      individual_chance_of_bestness.sort_by {|_k, v| v}.reverse.each do |individual, chance|
        puts "#{individual}\t#{'%0.3f' % chance}"
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
      count_writer.printf "#{game.board}\t#{suit}\t#{point_count_dir}\t#{deal.hcp(partnership)}\t#{total_points}\t" \
             "#{fit}\t#{spade_fit}\t#{heart_fit}\t#{partnership_balanced}\t#{unstopped_suits}\t#{player_best_minimal_contracts}\t" \
             "#{partner_best_minimal_contracts};"
      count_writer.printf "#{player_best_minimal_contracts};"
      count_writer.printf "#{partner_best_minimal_contracts}\n"
    end
  end
end
