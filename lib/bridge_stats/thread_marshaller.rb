module BridgeStats
  class ThreadMarshaller
    attr_accessor :board_data, :player_best_minimal_contracts, :partner_best_minimal_contracts

    def marshal(board_characteristics_provider)
      "#{board_characteristics_provider.board}\t"\
      "#{board_characteristics_provider.suit}\t"\
      "#{board_characteristics_provider.point_count_dir}\t"\
      "#{board_characteristics_provider.partnership_hcp}\t"\
      "#{board_characteristics_provider.partnership_total_points}\t"\
      "#{board_characteristics_provider.fit}\t"\
      "#{board_characteristics_provider.spade_fit}\t"\
      "#{board_characteristics_provider.heart_fit}\t"\
      "#{board_characteristics_provider.is_partnership_balanced}\t"\
      "#{board_characteristics_provider.unstopped_suit_count}\t"\
      "#{board_characteristics_provider.player_best_minimal_contracts}\t"\
      "#{board_characteristics_provider.partner_best_minimal_contracts};"\
      "#{board_characteristics_provider.player_best_minimal_contracts};"\
      "#{board_characteristics_provider.partner_best_minimal_contracts}\n"
    end

    def unmarshal(string)
      result = string.chomp.split(';')
      self.board_data = result[0]
      self.player_best_minimal_contracts = result[1]
      self.partner_best_minimal_contracts = result[2]
    end
  end
end
