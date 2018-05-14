require 'portable_bridge_notation'
require_relative 'parallelizer'
require_relative 'thread_marshaller'
require 'pp'
module BridgeStats
  ## Build the joint empirical distribution
  class Builder
    attr_reader :player_satisfying
    attr_reader :partner_satisfying
    attr_accessor :thread_marshaller
    attr_accessor :deal
    attr_accessor :ddt
    attr_accessor :game
    attr_accessor :matching_boards

    attr_accessor :board, :suit, :point_count_dir, :partnership_hcp, :partnership_total_points,
                  :fit, :spade_fit, :heart_fit, :is_partnership_balanced, :unstopped_suit_count,
                  :player_best_minimal_contracts, :partner_best_minimal_contracts

    def initialize
      @player_satisfying = Hash.new { |h, k| h[k] = 0 }
      @partner_satisfying = Hash.new { |h, k| h[k] = 0 }
      @matching_boards = ''
      puts "board\tsuit\tpoint count dir\thcp\ttotal points\t" \
             "fit\tspade fit\theart fit\teach partner is balanced?\tunstopped suits\tplayer best minimal contracts\t" \
             "partner best minimal contracts\n"
      file_name_prefix = '/Users/tim/BackedUpToMacMini/GTD/DIGITAL_REFERENCE/BRIDGE/20000_pbn_games/fourways-20000-'
      parallelizer = Parallelizer.new(Array.new(4) { |n| File.open("#{file_name_prefix}#{n+1}.rbmarshal") },
                                      method(:forked_handle_file), method(:count_writer=))
      parallelizer.run(&method(:unforked_handle_pipe_reader))

      puts "\n\n\nPlayer (N or E) Satisfying Boards:"
      print_sat_boards player_satisfying
      puts "\n\n\nPartner (S or W) Satisfying Boards:"
      print_sat_boards partner_satisfying
    end

    def count_writer=(io)
      self.thread_marshaller = ThreadMarshaller.new(io)
    end

    def forked_handle_file(file)
      self.game = Marshal.load(file)
      self.ddt = DoubleDummyTricks.new(game.supplemental_sections[
                                           :DoubleDummyTricks].tag_value)
      self.deal = Deal.new(game.deal)
      hypothesize(:e, :w, :c)
      hypothesize(:e, :w, :d)
      hypothesize(:n, :s, :c)
      hypothesize(:n, :s, :d)
    end

    def unforked_handle_pipe_reader(reader)
      self.thread_marshaller = ThreadMarshaller.new(reader) if thread_marshaller.nil?
      thread_marshaller.unmarshal(reader)
      puts thread_marshaller.board_data
      player_satisfying[thread_marshaller.player_best_minimal_contracts] += 1
      partner_satisfying[thread_marshaller.partner_best_minimal_contracts] += 1
    end

    def print_sat_boards(whom)
      puts "count\tproportion\tbest minimal contract(s)\n"
      total = whom.values.inject(0) { |ttl, count_of_boards| ttl + count_of_boards }
      individual_chance_of_bestness = Hash.new { |h, k| h[k] = 0 }
      whom.sort_by { |_k, v| v }.reverse.each do |contracts, count_of_boards|
        set_proportion = count_of_boards / total.to_f
        puts "#{count_of_boards}\t#{'%0.3f' % set_proportion}\t#{contracts}\n"
        contracts.split(',').each { |i| individual_chance_of_bestness[i] += set_proportion }
      end
      puts "\nindividual contract\tchance it is a best minimal contract"
      individual_chance_of_bestness.sort_by { |_k, v| v }.reverse.each do |individual, chance|
        puts "#{individual}\t#{'%0.3f' % chance}"
      end
    end

    def hypothesize(player, partner, suit)
      partnership = player == :n ? :ns : :ew
      self.board = game.board
      self.suit = suit
      self.partnership_hcp = deal.hcp(partnership)
      player_length = deal.hand(player).suit_length(suit)
      partner_length = deal.hand(partner).suit_length(suit)
      self.fit = player_length + partner_length
      return unless fit >= 9
      self.spade_fit = deal.hand(player).suit_length(:s) + deal.hand(partner).suit_length(:s)
      return unless spade_fit < 8
      self.heart_fit = deal.hand(player).suit_length(:h) + deal.hand(partner).suit_length(:h)
      return unless heart_fit < 8
      self.point_count_dir = if player_length > partner_length
                          player
                        elsif partner_length > player_length
                          partner
                        elsif deal.total_partnership_points(player, suit) > deal.total_partnership_points(partner, suit)
                          player
                        else
                          partner
                        end
      self.partnership_total_points = deal.total_partnership_points(point_count_dir, suit)
      return unless partnership_total_points >= 23
      return unless partnership_total_points <= 29
      self.is_partnership_balanced = deal.hand(player).balanced && deal.hand(partner).balanced
      return if is_partnership_balanced
      self.unstopped_suit_count = deal.unstopped_suit_count(partnership)
      return unless unstopped_suit_count > 0

      self.player_best_minimal_contracts = ddt.best_minimal_contracts(player).to_a.sort.join(',')
      self.partner_best_minimal_contracts = ddt.best_minimal_contracts(partner).to_a.sort.join(',')
      thread_marshaller.marshal(self)
    end
  end
end
