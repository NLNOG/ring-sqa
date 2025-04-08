# frozen_string_literal: true

# Core functionality for the Ring SQA (Service Quality Assurance) system
# This module handles the main application logic and thread management

require 'socket'
require_relative 'cfg'
require_relative 'database'
require_relative 'poller'
require_relative 'analyzer'
require_relative 'nodes'

module Ring
  class SQA
    # Main execution method that manages all system components
    # Creates and manages threads for different system components:
    # - Responder: Handles incoming requests
    # - Sender: Manages outgoing communications
    # - Receiver: Processes incoming data
    # - Analyzer: Analyzes system metrics
    def run
      # Ensure thread exceptions are not silently ignored
      Thread.abort_on_exception = true
      @threads = []

      begin
        # Create and store references to all component threads
        @threads << Thread.new { Responder.new }
        @threads << Thread.new { Sender.new @database, @nodes }
        @threads << Thread.new { Receiver.new @database }
        @threads << Thread.new { Analyzer.new(@database, @nodes).run }

        # Wait for all threads to complete (they typically run indefinitely)
        @threads.each(&:join)
      rescue StandardError => e
        # Log any errors and ensure all threads are properly terminated
        Log.error "Error in SQA run: #{e.message}"
        @threads.each { |t| t.kill if t.alive? }
        raise
      end
    end

    private

    # Initialize the SQA system
    # Sets up logging, database, and node management
    def initialize
      require_relative 'log'
      @database = Database.new

      # Verify database is properly initialized
      raise StandardError, "Database initialization failed: Table 'pings' does not exist" unless @database.table_exists?

      @nodes = Nodes.new
      run
    end
  end
end
