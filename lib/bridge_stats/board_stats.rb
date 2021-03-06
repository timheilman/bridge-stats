module BridgeStats
  class BoardStats
    SUITS = [:c, :d, :h, :s]
    attr_reader :deal, :ddt, :board

    def initialize(game)
      @deal = CachingWrapper.new(Deal.new(game.deal))
      @ddt = CachingWrapper.new(DoubleDummyTricks.new(game.supplemental_sections[:DoubleDummyTricks].tag_value))
      @board = game.board
    end

    def suit
      :c
    end

    def satisfy_experiment?(dealer)
      partnership = deal.partnership(dealer)

      return false if deal.fit(partnership, suit) < 9
      return false if deal.fit(partnership, :s) >= 8 || deal.fit(partnership, :h) >= 8
      return false if deal.total_partnership_points(partnership, suit) < 23
      return false if deal.total_partnership_points(partnership, suit) > 29
      return false if deal.balanced?(dealer) && deal.balanced?(deal.partner(dealer))
      return false if deal.unstopped_suit_count(partnership).zero?
      true
    end

    def self.excel_header
      "board\t"\
      "declarer\t"\
      "suit\t"\
      "point count dir\t"\
      "hcp\t"\
      "total points\t"\
      "fit\t"\
      "spade fit\t"\
      "heart fit\t"\
      "each partner is balanced?\t"\
      "unstopped suits\t"\
      "best minimal contracts\n"
    end

    def board_excel_record(dealer)
      partnership = deal.partnership(dealer)

      "#{board}\t"\
      "#{dealer}\t"\
      "#{suit}\t"\
      "#{deal.point_count_dir(partnership, suit)}\t"\
      "#{deal.hcp(partnership)}\t"\
      "#{deal.total_partnership_points(partnership, suit)}\t"\
      "#{deal.fit(partnership, suit)}\t"\
      "#{deal.fit(partnership, :s)}\t"\
      "#{deal.fit(partnership, :h)}\t"\
      "#{deal.balanced?(dealer) && deal.balanced?(deal.partner(dealer))}\t"\
      "#{deal.unstopped_suit_count(partnership)}\t"\
      "#{best_minimal_contracts(dealer)}\n"\
    end

    def best_minimal_contracts(dealer)
      ddt.best_minimal_contracts(dealer).to_a.sort.join(',')
    end

  end
end
