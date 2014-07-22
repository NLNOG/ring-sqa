require 'sequel'
require 'sqlite3'

module Ring
class SQA

  class Database
    def add record
      record[:time]    = Time.now.utc.to_i
      record[:latency] = nil
      record[:result]  = 'no response'
      Log.debug "adding '#{record}' to database"
      Ping.new(record).save
    end

    def update record_id, result, latency=nil
      if record = Ping[record_id]
        Log.debug "updating record_id '#{record_id}' with result '#{result}' and latency '#{latency}'"
        record.update(:result=>result, :latency=>latency)
      else
        Log.error "wanted to update record_id #{record_id}, but it does not exist"
      end
    end

    def not_ok first_id
      max_id = (Ping.max(:id) or first_id)
      [max_id, Ping.where(:id=>first_id..max_id).exclude(:result => 'ok')]
    end

    def up_since? id, peer
      Ping.where{id > id}.where(:peer=>peer).count > 0
    end

    private

    def initialize
      Sequel::Model.plugin :schema
      file = CFG.ipv6? ? 'ipv6.db' : 'ipv4.db'
      file = File.join CFG.directory, file
      @db = Sequel.sqlite(file, :max_connections => 3, :pool_timeout => 60)
      require_relative 'database/model.rb'
      Ping.where().delete  #start with empty database
    end
  end

end
end
