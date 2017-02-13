require 'bridge'
require 'portable_bridge_notation'

class BridgeStats::Builder
  def initialize
    importer = PortableBridgeNotation::ImporterFactory.get_instance # get_best_effort might log instead of raise...
    importer.attach(self)
    importer.import # io; todo: get a test file in here
    # todo: provide some error configuration; some way to error-out per-game

  end

  def with_new_game(index_within_io: index_within_io)

  end
  def with_dealt_card(direction: direction, rank: rank, suit: suit)
    pp Bridge::Card.for(suits: [suit], ranks: [rank])[0]
  end
end