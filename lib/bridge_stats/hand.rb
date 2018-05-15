module BridgeStats
  # Represents a hand within a bridge game
  class Hand
    attr_reader :hand

    @hcp_for_rank = { A: 4, K: 3, Q: 2, J: 1 }
    @hcp_for_rank.default = 0

    def self.hcp_for_rank(rank)
      @hcp_for_rank[rank]
    end

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
        yield rank.to_sym
      end
    end

    def hcp
      hand.inject(0) do |hcp, (_suit, ranks)|
        hcp + with_each_rank(ranks).inject(0) do |hcp_for_suit, rank|
          hcp_for_suit + self.class.hcp_for_rank(rank)
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

    def balanced?
      blankleton_count(0).zero? && blankleton_count(1).zero? && blankleton_count(2) <= 1
    end

    def unstopped_suits
      with_each_suit.inject([]) do |unstopped_suits, (suit, ranks)|
        if stopped(ranks)
          unstopped_suits
        else
          unstopped_suits << suit
        end
      end
    end

    # rubocop complains, but this is the most *readable* way to express it
    def stopped(ranks)
      ranks.include?('A') || # full stopper
        (ranks.include?('K') && ranks.length >= 2) || # potentially a half-stopper
        (ranks.include?('Q') && ranks.length >= 3) # potentially a less-than-half stopper
#       || (ranks.include?('J') && ranks.length >= 4) empirically not considered a stopper in Zack's analysis
    end
  end
end
