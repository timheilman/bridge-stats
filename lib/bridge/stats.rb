module Bridge end
module Bridge::Stats
  autoload :Builder, File.expand_path('../stats/builder', __FILE__)
end