require 'sequel'
require 'sqlite3'

module Ring
class SQA

  class Database
    def add record
      record[:time]    = Time.now.utc.to_i
      record[:latency] = nil
      record[:result]  = 'no response'
      Log.debug "adding '#{record}' to database" if CFG.debug?
      Ping.new(record).save
    end

    def update record_id, result, latency=nil
      if record = Ping[record_id]
        Log.debug "updating record_id '#{record_id}' with result '#{result}' and latency '#{latency}'" if CFG.debug?
        record.update(:result=>result, :latency=>latency)
      else
        Log.error "wanted to update record_id #{record_id}, but it does not exist"
      end
    end

    def nodes_down first_id
      max_id = (Ping.max(:id) or first_id)
      [max_id, Ping.distinct.where(:id=>first_id..max_id).exclude(:result => 'ok')]
    end

    def up_since? id, peer
      Ping.where{id > id}.where(:peer=>peer).count > 0
    end

    def purge older_than=3600
      Ping.where{time < (Time.now.utc-older_than).to_i}.delete
    end

    private

    def initialize
      Sequel::Model.plugin :schema
      sequel_opts = { max_connections: 3, pool_timout: 60 }
      if CFG.ram_database?
        @db = Sequel.sqlite sequel_opts
      else
        file = CFG.ipv6? ? 'ipv6.db' : 'ipv4.db'
        file = File.join CFG.directory, file
        File.unlink file rescue nil # delete old database
        @db = Sequel.sqlite file, sequel_opts
      end
      require_relative 'database/model.rb'
    end
  end

end
end
