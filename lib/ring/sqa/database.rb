# frozen_string_literal: true

# Database management for Ring SQA system
# Handles all database operations including CRUD operations and maintenance

require 'sequel'
require 'sqlite3'

module Ring
  class SQA
    class Database
      # Add a new record to the database
      # @param record [Hash] The record to add with timestamp and initial state
      # @return [Ping] The created Ping object
      def add(record)
        @db.transaction do
          record[:time]    = Time.now.utc.to_i
          record[:latency] = nil
          record[:result]  = 'no response'
          ping = Ping.new(record).save
          Log.debug "added '#{record}' to database with id #{ping.id}" if CFG.debug?
          return ping
        rescue Sequel::Error => e
          Log.error "Database error while adding record: #{e.message}"
          raise
        end
      end

      # Update an existing record with new results
      # @param record_id [Integer] The ID of the record to update
      # @param result [String] The new result status
      # @param latency [Integer, nil] The measured latency, if available
      def update(record_id, result, latency = nil)
        @db.transaction do
          if record = Ping[record_id]
            Log.debug "updating record_id '#{record_id}' with result '#{result}' and latency '#{latency}'" if CFG.debug?
            record.update(result: result, latency: latency)
          else
            Log.error "wanted to update record_id #{record_id}, but it does not exist"
          end
        rescue Sequel::Error => e
          Log.error "Database error while updating record: #{e.message}"
          raise
        end
      end

      # Get information about nodes that are down
      # @param first_id [Integer] The starting ID to check from
      # @return [Array] Array containing max_id and list of down nodes
      def nodes_down(first_id)
        @db.transaction do
          max_id = (Ping.max(:id) or first_id)
          [max_id, id_range(first_id, max_id).exclude(result: 'ok')]
        end
      end

      # Check if a node has been up since a given ID
      # @param id [Integer] The ID to check from
      # @param peer [String] The peer to check
      # @return [Boolean] True if the node has been up since the given ID
      def up_since?(id, peer)
        @db.transaction do
          Ping.where { id > id }.where(peer: peer.to_s).count.positive?
        end
      end

      # Purge old records from the database
      # @param older_than [Integer] Age in seconds after which to purge records
      def purge(older_than = 3600)
        @db.transaction do
          Ping.where { time < (Time.now.utc - older_than).to_i }.delete
          @db.run('VACUUM') if CFG.vacuum_on_purge?
        rescue Sequel::Error => e
          Log.error "Database error while purging: #{e.message}"
          raise
        end
      end

      # Get a range of records by ID
      # @param first [Integer] Starting ID
      # @param last [Integer] Ending ID
      # @return [Sequel::Dataset] Dataset containing the requested records
      def id_range(first, last)
        @db.transaction do
          Ping.distinct.where(id: first..last)
        end
      end

      # Check if the pings table exists
      # @return [Boolean] True if the table exists
      def table_exists?
        @db.table_exists?(:pings)
      rescue Sequel::Error => e
        Log.error "Database error while checking table existence: #{e.message}"
        false
      end

      private

      # Initialize the database connection
      # Sets up connection options and creates the database if needed
      def initialize
        sequel_opts = {
          max_connections: 1,
          pool_timeout: 60,
          single_threaded: true
        }

        begin
          if CFG.ram_database?
            @db = Sequel.sqlite sequel_opts
          else
            file = '%s.db' % CFG.afi
            file = File.join CFG.directory, file
            File.unlink(file) if CFG.reset_database?
            @db = Sequel.sqlite file, sequel_opts
          end
          create_db
          require_relative 'database/model'
        rescue Sequel::Error => e
          Log.error "Database initialization error: #{e.message}"
          raise
        end
      end

      # Create the pings table if it doesn't exist
      # Defines the schema for storing ping results
      def create_db
        @db.create_table?(:pings) do
          primary_key :id
          Fixnum      :time
          String      :peer
          Fixnum      :latency
          String      :result
        end
      rescue Sequel::Error => e
        Log.error "Database creation error: #{e.message}"
        raise
      end
    end
  end
end
