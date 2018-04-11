module BridgeStats
  # Represents the deal of hands for a bridge game
  class Deal
    attr_reader :deal

    def initialize(deal)
      @deal = deal.collect { |dir, hand| [dir, Hand.new(hand)] }.to_h
    end

    def hand(dir)
      deal[dir]
    end

    def with_each_dir(dirs)
      return to_enum(:with_each_dir, dirs) unless block_given?
      dirs.to_s.split(//).each do |dir_s|
        yield dir_s.to_sym
      end
    end

    def hcp(dirs)
      with_each_dir(dirs).inject(0) do |hcp, dir|
        hcp + hand(dir).hcp
      end
    end

    def total_partnership_points(dir_with_long_trump, trump_suit)
      partner = partner(dir_with_long_trump)
      hand(dir_with_long_trump).total_points_long +
        hand(partner).total_points_short(trump_suit)
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
        fit + hand(dir).suit_length(suit)
      end
    end

    def blankleton_count(shortness, dirs)
      with_each_dir(dirs).inject(0) do |count, dir|
        count + hand(dir).blankleton_count(shortness)
      end
    end

    def unstopped_suit_count(dirs)
      with_each_dir(dirs).inject([:c, :d, :h, :s]) do |unstopped_suits, dir|
        unstopped_suits & hand(dir).unstopped_suits
      end.length
    end
  end
end
