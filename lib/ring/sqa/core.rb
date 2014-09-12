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
      Thread.new { Responder.new }
      Thread.new { Sender.new @database, @nodes }
      Thread.new { Receiver.new @database }
      Analyzer.new(@database, @nodes).run
    end

    private

    def initialize
      require_relative 'log'
      @database  = Database.new
      # make sure Ping is created
      raise "Table 'pings' does not exist" unless Ring::SQA::Database::Ping.table_exists?
      @nodes     = Nodes.new
      run
    end

  end
end
