require 'portable_bridge_notation'
require 'parallel'
require_relative 'board_stats'
require 'pp'
module BridgeStats
  ## Build the joint empirical distribution
  class Builder
    attr_reader :satisfying_best_minimal_contracts

    def initialize
      @satisfying_best_minimal_contracts = Hash.new {|h, k| h[k] = Hash.new {|h1, k1| h1[k1] = 0}}
      puts BoardStats.excel_header
      file_name_prefix = '/Users/tim/BackedUpToMacMini/GTD/DIGITAL_REFERENCE/BRIDGE/20000_pbn_games/fourways-20000-'

      Parallel.map(Array.new(4) {|n| File.open("#{file_name_prefix}#{n + 1}.rbmarshal")}) do |file|
        forked_handle_file(file)
      end.each do |satisfying_board_stats_array|
        satisfying_board_stats_array.each do |satisfying_board_stats_and_dir|
          handle_satisfying_board_stats(satisfying_board_stats_and_dir)
        end
      end

      [:n, :e, :s, :w].each do |dir|
        puts "\n\n\n#{dir.to_s.upcase} Satisfying Boards:"
        print_sat_boards satisfying_best_minimal_contracts[dir]
      end
    end

    def forked_handle_file(file)
      results = []
      until file.eof?
        # intent: we want to ignore the actual dealer and consider all four options for each board
        board_stats = BoardStats.new(Marshal.load(file))
        [:n, :e, :s, :w].each do |dir|
          results << [board_stats, dir] if board_stats.satisfy_experiment?(dir)
        end
      end
      results
    end

    def handle_satisfying_board_stats(satisfying_board_stats_and_dir)
      dealer = satisfying_board_stats_and_dir[1]
      board_stats = satisfying_board_stats_and_dir[0]
      puts board_stats.board_excel_record(dealer)
      satisfying_best_minimal_contracts[dealer][board_stats.best_minimal_contracts(dealer)] += 1
    end

    def print_sat_boards(whom)
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

  end
end
