require 'pp'
require 'socket'
require_relative 'cfg'
require_relative 'database'
require_relative 'poller'
require_relative 'analyzer'
require_relative 'nodes'

module Ring
  class SQA
    def run
      Thread.abort_on_exception = true
      @responder[:thread] = Thread.new { Responder.new @responder[:queue] }
      @querier[:thread]   = Thread.new { Querier.new @querier[:queue], @database, @nodes }
      Analyzer.new(@database, @nodes).run
    end

    private

    def initialize
      require_relative 'log'
      @querier   = { queue: Queue.new }
      @responder = { queue: Queue.new }
      @database  = Database.new
      @nodes     = Nodes.new
      run
    end

  end
end
