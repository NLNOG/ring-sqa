require_relative 'alarm'

module Ring
class SQA

  class Analyzer
    SLEEP         = 10 # sleep between analyze rounds
    INFLIGHT_WAIT = 1  # how long to wait for inflight records
    def run
      loop do
        @db_id_seen, records = @db.not_ok(@db_id_seen+1)
        sleep INFLIGHT_WAIT
        records.all.each do |record|
          @alarm.set record[:id], record[:peer]
        end
        Log.debug "Analyzer loop at end"
        sleep SLEEP
      end
    end

    private

    def initialize database, nodes
      @db         = database
      @nodes      = nodes
      @alarm      = Alarm.new @db
      @db_id_seen = 0
    end
  end

end
end
