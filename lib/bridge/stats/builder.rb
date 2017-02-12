require 'bridge'
require 'portable_bridge_notation'

require_relative '../stats'

class Bridge::Stats::Builder
  def initialize
    pp Bridge::Card.all[0]
    pp PortableBridgeNotation::IoParser.each_game_string nil
  end
end