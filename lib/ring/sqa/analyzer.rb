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
        @buffer.push records.map { |record| record.peer }
        @buffer.exceed_median? ? @alarm.set(@buffer.exceeding_nodes) : @alarm.clear
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
      init_nodes = Array.new 99, ''
      @array = Array.new max_size, init_nodes
    end
    def push e
      @array.shift
      @array.push e
    end
    def median of_first=27
      of_first = of_first-1
      middle   = of_first/2
      node_count[0..of_first].sort[middle]
    end
    def exceed_median? last=3, tolerance=CFG.analyzer.tolerance
      first = @max_size-last
      violate = (median+1)*tolerance
      node_count[first..-1].all? { |e| e > violate }
    end
    def node_count
      @array.map { |nodes| nodes.size }
    end
    def exeeding_nodes
      exceed = @array[27] & @array[28] & @array[29]
      exceed - @array[0..26].flatten.uniq
    end
  end

end
end
