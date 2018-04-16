module BridgeStats
  # Given an array of ios, fork one process and create one
  # anonymous pipe pair for each io, provide (in child processes) the write pipe and the io repeatedly until it is eof?,
  # and finally (in the original process) provide the read pipes in order until all of them are eof?
  class Parallelizer
    attr_reader :ios, :io_handler, :write_pipe_receiver
    attr_accessor :read_pipes, :pids

    # ios contains the ios
    # io_handler is a lambda ready to receive each io in a child process repeatedly until eof?
    # write_pipe_receiver is a lambda ready to receive the write pipe once in each child process
    def initialize(ios, io_handler, write_pipe_receiver)
      @ios = ios
      @io_handler = io_handler
      @write_pipe_receiver = write_pipe_receiver
    end

    # expect repeated yields of each of ios.length read pipes until they are eof?
    def run(&block)
      self.read_pipes = []
      self.pids = []

      fork_io_readings
      pids.each { |pid| Process.wait(pid) }
      yield_read_pipes(&block)
    end

    private

    def fork_io_readings
      ios.each do |io|
        read_pipe, write_pipe = IO.pipe
        read_pipes << read_pipe
        # outfile = File.new("#{file_name_prefix}#{file_num +1}.rbmarshal", "w")
        fork_io_reading io, read_pipe, write_pipe
        write_pipe.close
      end
    end

    def fork_io_reading(io, read_pipe, write_pipe)
      pids << fork do
        read_pipe.close
        write_pipe_receiver.call(write_pipe)
        # importer.import {|game| build_distribution(game)}
        # importer.import {|game| Marshal.dump(game, outfile)}
        # outfile.close()
        io_handler.call(io) until io.eof?
        exit!(0)
      end
    end

    def yield_read_pipes
      read_pipes.each do |read_pipe|
        yield read_pipe until read_pipe.eof?
      end
    end
  end
end
