require 'sequel'
require 'sqlite3'

module Ring
class SQA

  class Database
    def add record
      @rows += 1
      Log.debug "adding '#{record}' to database"
      Ping.new(record).save
    end

    def median node
      Ping.where(:peer=>node).order(:latency).offset(@rows/2).first.latency
    end

    def latency_above node, violate
      Ping.where{Sequel.&({:peer=>node}, (latency >= violate))}.count
    end

    private

    def initialize
      Sequel::Model.plugin :schema
      @db = Sequel.sqlite(CFG[:db], :max_connections => 3, :pool_timeout => 60)
      require_relative 'database/model.rb'
      @rows = Ping.count
    end
  end

end
end
