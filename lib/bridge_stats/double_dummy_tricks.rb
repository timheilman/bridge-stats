module BridgeStats
  # represents the tag of the same name from PBN: what number of tricks can be made
  # in each strain with each declarer; one hex digit per character, in the order
  # N NT, N S, N H, N D, N C, S NT, ..., E C, W NT, W S, W H, W D, W C
  class DoubleDummyTricks
    @dirs = [:n, :s, :e, :w]
    @strains = [:nt, :s, :h, :d, :c]
    @trick_values = { nt: 30, s: 30, h: 30, d: 20, c: 20 }
    class << self
      attr_reader :dirs
      attr_reader :strains

      def trick_values(strain)
        @trick_values[strain]
      end
    end

    attr_reader :ddt

    def initialize(ddt)
      @ddt = ddt
    end

    def with_each_strain(dir)
      return enum_for :with_each_strain, dir unless block_given?
      index = self.class.dirs.find_index(dir) * 5
      self.class.strains.each do |strain|
        yield strain, ddt[index].to_i(16)
        index += 1
      end
    end

    def best_minimal_contracts(dir)
      with_each_strain(dir).inject([-350, []]) do |best_score_contracts_pair, (strain, tricks)|
        score = score_with_bonuses(strain, tricks)
        if score == best_score_contracts_pair[0]
          [score, best_score_contracts_pair[1] << minimal_contract(strain, tricks)]
        elsif score > best_score_contracts_pair[0]
          [score, [minimal_contract(strain, tricks)]]
        else
          best_score_contracts_pair
        end
      end[1].to_set
    end

    def minimal_contract(strain, tricks)
      case strain
      when :nt
        minimal_contract_nt tricks
      when :s, :h
        minimal_contract_major tricks, strain
      else
        minimal_contract_minor tricks, strain
      end
    end

    def minimal_contract_nt(tricks)
      return '1nt' if tricks <= 8
      return '3nt' if tricks <= 11
      return '6nt' if tricks == 12
      '7nt'
    end

    def minimal_contract_major(tricks, strain)
      return '1' + strain.to_s if tricks <= 9
      return '4' + strain.to_s if tricks <= 11
      return '6' + strain.to_s if tricks == 12
      '7' + strain.to_s
    end

    def minimal_contract_minor(tricks, strain)
      return '1' + strain.to_s if tricks <= 10
      return '5' + strain.to_s if tricks == 11
      return '6' + strain.to_s if tricks == 12
      '7' + strain.to_s
    end

    def score_with_bonuses(strain, tricks)
      return 50 * (tricks - 7) if tricks < 7
      making_score_with_bonuses strain, tricks
    end

    def making_score_with_bonuses(strain, tricks)
      score = 0
      score += 10 if strain == :nt
      tricks_less_book = tricks - 6
      score += tricks_less_book * self.class.trick_values(strain)
      score += (score < 100 ? 50 : 300)
      score += 500 if tricks_less_book == 6
      score += 1000 if tricks_less_book == 7
      score
    end
  end
end
