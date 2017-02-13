require 'bridge'
require 'portable_bridge_notation'

class BridgeStats::Builder
  def initialize
    pp Bridge::Card.all[0]
    importer = PortableBridgeNotation::Importer.new
    importer.attach(self)
    importer.import # io; todo: get a test file in here
  end

  def with_dealt_card(direction: direction, rank: rank, suit: suit)
    pp Bridge::Card.for(suits: [suit], ranks: [rank])[0]
  end
end