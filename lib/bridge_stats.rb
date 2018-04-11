# Namespace module for computing statistics from PBN files
module BridgeStats
  autoload :Builder, File.expand_path('../bridge_stats/builder', __FILE__)
  autoload :Deal, File.expand_path('../bridge_stats/deal', __FILE__)
  autoload :Hand, File.expand_path('../bridge_stats/hand', __FILE__)
  autoload :DoubleDummyTricks, File.expand_path('../bridge_stats/double_dummy_tricks', __FILE__)
end
