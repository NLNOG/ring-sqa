require 'sequel'
require 'sqlite3'

module Ring
class SQA

  class Database
    def add record
      Log.debug "adding '#{record}' to database"
      Ping.new(record).save
    end

    private

    def initialize
      Sequel::Model.plugin :schema
      @db = Sequel.sqlite(CFG[:db], :max_connections => 3, :pool_timeout => 60)
      require_relative 'database/model.rb'
    end
  end

end
end
