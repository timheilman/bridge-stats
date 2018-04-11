module BridgeStats
  class Hand
    attr_reader :hand

    def initialize(hand)
      @hand = hand
    end

    def with_each_suit
      return to_enum(:with_each_suit) unless block_given?
      hand.keys.each do |suit|
        yield suit, hand[suit]
      end
    end

    def with_each_rank(ranks)
      return to_enum(:with_each_rank, ranks) unless block_given?
      ranks.split(//).each do |rank|
        yield rank
      end
    end

    def hcp
      hand.inject(0) do |hcp, (_suit, ranks)|
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

    def long_points
      hand.inject(0) do |long_points, (_suit, ranks)|
        long_points + [0, ranks.length - 4].max
      end
    end

    def short_points(trump_suit)
      hand.inject(0) do |short_points, (suit, ranks)|
        if trump_suit == suit
          short_points
        else
          short_points + [0, 1 + 2 * (2 - ranks.length)].max
        end
      end
    end

    def total_points_long
      hcp + long_points
    end

    def total_points_short(trump_suit)
      hcp + short_points(trump_suit)
    end

    def suit_length(suit)
      hand[suit].length
    end

    def blankleton_count(shortness)
      with_each_suit.inject(0) do |count, (_suit, ranks)|
        if ranks.length == shortness
          count + 1
        else
          count
        end
      end
    end

    def unstopped_suits
      with_each_suit.inject([]) do |unstopped_suits, (suit, ranks)|
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
