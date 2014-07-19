require_relative 'alarm'

module Ring
class SQA

  class Analyzer
    #SLEEP = 30*60
    SLEEP = 10
    VIOLATE_MULTIPLIER = 3.5
    def run
      loop do
        @nodes.list.each do |node|
          median = @db.median node
          violate = median * VIOLATE_MULTIPLIER
          next unless (@db.latency_above node, violate) > 0
          @alarm.send "#{node} latency above alarm threshold"
        end
        Log.debug "Analyzer loop at end"
        sleep SLEEP
      end
    end

    private

    def initialize database, nodes
      @db    = database
      @nodes = nodes
      @alarm = Alarm.new
    end
  end

end
end
