require 'bridge'
require 'bridge/pbn'

require_relative '../stats'

class Bridge::Stats::Builder
  def initialize
    pp Bridge::Card.all[0]
    pp Bridge::Pbn::IoParser.each_game_string nil
  end
end