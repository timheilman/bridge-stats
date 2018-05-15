module BridgeStats
  # Represents the deal of hands for a bridge game
  class Deal
    attr_reader :deal

    def initialize(deal)
      @deal = deal.collect {|dir, hand| [dir, Hand.new(hand)]}.to_h
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

    def partnership(dealer)
      dealer == :n || dealer == :s ? :ns : :ew
    end

    def total_partnership_points(dirs, trump_suit)
      point_count_dir = dirs.length > 1 ? point_count_dir(dirs, trump_suit) : dirs
      partner = partner(point_count_dir)
      hand(point_count_dir).total_points_long +
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
      else
        raise Exception "unknown direction #{dir}"
      end
    end

    def point_count_dir(dirs, suit)
      player = dirs.to_s[0].to_sym
      partner = dirs.to_s[1].to_sym
      longer_trump_dir = longer_trump_dir(player, partner, suit)
      return longer_trump_dir unless longer_trump_dir.nil?
      if total_partnership_points(player, suit) >= total_partnership_points(partner, suit)
        player
      else
        partner
      end
    end

    def longer_trump_dir(player, partner, suit)
      player_length = hand(player).suit_length(suit)
      partner_length = hand(partner).suit_length(suit)
      if player_length > partner_length
        player
      elsif partner_length > player_length
        partner
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

    def balanced?(dir)
      hand(dir).balanced?
    end
  end
end
