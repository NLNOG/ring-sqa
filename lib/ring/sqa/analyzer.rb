require_relative 'alarm'

module Ring
class SQA

  class Analyzer
    INTERVAL      = 60 # how often to run analyze loop
    INFLIGHT_WAIT = 1  # how long to wait for inflight records
    def run
      loop do
        start = Time.now
        @db.purge
        @db_id_seen, records = @db.nodes_down(@db_id_seen+1)
        sleep INFLIGHT_WAIT
        records = records.all
        @buffer.push records.size
        @buffer.exceed_median? ? @alarm.set : @alarm.clear
        delay = INTERVAL-(Time.now-start)
        if delay > 0
          sleep delay
        else
          Log.error "Analyzer loop took longer than #{INTERVAL}, wanted to sleep for #{delay}s"
        end
      end
    end

    private

    def initialize database, nodes
      @db         = database
      @nodes      = nodes
      @alarm      = Alarm.new @db
      @buffer     = AnalyzeBuffer.new
      @db_id_seen = 0
    end
  end

  class AnalyzeBuffer
    def initialize max_size=30
      @max_size = max_size
      @array = Array.new max_size, 99999
    end
    def push e
      @array.shift
      @array.push e
      Log.debug "Analyzer Buffer: '#{@array.to_s}'"
    end
    def median of_first=27
      of_first = of_first-1
      middle   = of_first/2
      @array[0..of_first].sort[middle]
    end
    def exceed_median? last=3, tolerance=CFG.analyzer.tolerance
      first = @max_size-last
      my_median = median
      violate = (my_median+1)*tolerance
      Log.debug "my_median is: '#{my_median}' and violate is: '#{violate}'"
      exceed = @array[first..-1].all? { |e| e > violate }
      Log.debug "exceed_median returns: '#{exceed.inspect}'"
      exceed
    end
  end

end
end
