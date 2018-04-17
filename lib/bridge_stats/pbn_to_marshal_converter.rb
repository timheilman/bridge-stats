require 'portable_bridge_notation'
require_relative 'parallelizer'
module BridgeStats
  # Transform .pbn files to .rbmarshal files (Marshal.dumped PortableBridgeNotation::Api::Game files), which are
  # much faster to analyze
  class PbnToMarshalConverter
    PBN_REGEXP = /\.pbn$/

    def convert(file_names)
      pbn_file_names = file_names.select { |f| f =~ PBN_REGEXP }
      raise Exception("No files ending in `.pbn' matched `#{file_names}'; exiting") if pbn_file_names.empty?
      puts "Converting these files, one fork per file: #{pbn_file_names}"
      Parallelizer.new(pbn_file_names.map { |f| File.open(f, 'r') }, method(:handle_file), nil).run
    end

    def handle_file(file)
      outfile = File.open(file.path.sub(PBN_REGEXP, '.rbmarshal'), 'w')
      PortableBridgeNotation::Api::Importer.create(io: file).import { |game| Marshal.dump(game, outfile) }
      outfile.close
    end
  end
end
