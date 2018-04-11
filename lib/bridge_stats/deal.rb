module BridgeStats
  class Deal
    attr_reader :deal

    def initialize(deal)
      @deal = deal
    end

    def with_each_suit(dir)
      return to_enum(:with_each_suit, dir) unless block_given?
      [:c, :d, :h, :s].each do |suit|
        yield suit, deal[dir][suit]
      end
    end

    def with_each_rank(ranks)
      return to_enum(:with_each_rank, ranks) unless block_given?
      ranks.split(//).each do |rank|
        yield rank
      end
    end

    def with_each_dir(dirs)
      return to_enum(:with_each_dir, dirs) unless block_given?
      case dirs
      when :ns
        yield :n
        yield :s
      when :ew
        yield :e
        yield :w
      else
        yield dirs
      end
    end

    def hcp(dirs)
      with_each_dir(dirs).inject(0) do |hcp, dir|
        hcp + hcp_single_dir(dir)
      end
    end

    def hcp_single_dir(dir)
      with_each_suit(dir).inject(0) do |hcp, (_suit, ranks)|
        hcp + with_each_rank(ranks).inject(0) do |hcp_for_suit, rank|
          case rank
          when 'A'
            hcp_for_suit + 4
          when 'K'
            hcp_for_suit + 3
          when 'Q'
            hcp_for_suit + 2
          when 'J'
            hcp_for_suit + 1
          else
            hcp_for_suit
          end
        end
      end
    end

    def long_points(dir)
      with_each_suit(dir).inject(0) do |long_points, (_suit, ranks)|
        long_points + [0, ranks.length - 4].max
      end
    end

    def short_points(dir, trump_suit)
      with_each_suit(dir).inject(0) do |short_points, (suit, ranks)|
        if trump_suit == suit
          short_points
        else
          short_points + [0, 1 + 2 * (2 - ranks.length)].max
        end
      end
    end

    def total_points(declarer, trump_suit)
      partner = partner(declarer)
      hcp(declarer) + long_points(declarer) +
          hcp(partner) + short_points(partner, trump_suit)
    end

    def partner(dir)
      case dir
      when :n
        :s
      when :s
        :n
      when :e
        :w
      when :w
        :e
      end
    end

    def fit(dirs, suit)
      with_each_dir(dirs).inject(0) do |fit, dir|
        fit + deal[dir][suit].length
      end
    end

    def blankleton_count(shortness, dirs)
      with_each_dir(dirs).inject(0) do |count, dir|
        count + blankleton_count_single_dir(shortness, dir)
      end
    end

    def blankleton_count_single_dir(shortness, dir)
      with_each_suit(dir).inject(0) do |count, (_suit, ranks)|
        if ranks.length == shortness
          count + 1
        else
          count
        end
      end
    end

    def unstopped_suit_count(dirs)
      with_each_dir(dirs).inject([:c, :d, :h, :s]) do |unstopped_suits, dir|
        unstopped_suits & unstopped_suits(dir)
      end.length
    end

    def unstopped_suits(dir)
      with_each_suit(dir).inject([]) do |unstopped_suits, (suit, ranks)|
        if ranks.include?('A') ||
            (ranks.include?('K') && ranks.length >= 2) ||
            (ranks.include?('Q') && ranks.length >= 3) ||
            (ranks.include?('J') && ranks.length >= 4)
          unstopped_suits
        else
          unstopped_suits << suit
        end
      end
    end
  end
end
