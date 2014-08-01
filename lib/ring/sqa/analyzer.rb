require_relative 'alarm'

module Ring
class SQA

  class Analyzer
    INTERVAL      = 60 # how often to run analyze loop
    INFLIGHT_WAIT = 1  # how long to wait for inflight records
    def run
      sleep INTERVAL
      loop do
        start = Time.now
        @db.purge
        @db_id_seen, records = @db.nodes_down(@db_id_seen+1)
        sleep INFLIGHT_WAIT
        records = records.all
        @buffer.push records.map { |record| record.peer }
        @buffer.exceed_median? ? @alarm.set(@buffer) : @alarm.clear(@buffer)
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
      @alarm      = Alarm.new @nodes
      @buffer     = AnalyzeBuffer.new @nodes.all.size
      @db_id_seen = 0
    end
  end

  class AnalyzeBuffer
    attr_reader :array
    def initialize nodes_count, max_size=CFG.analyzer.size, median_of=CFG.analyzer.median_of
      @max_size   = max_size
      @median_of  = median_of
      nodes_count = CFG.fake? ? 0 : nodes_count
      init_nodes  = Array.new nodes_count * 2, ''
      @array      = Array.new max_size, init_nodes
    end
    def push e
      @array.shift
      @array.push e
    end
    def median
      last   = @median_of-1
      node_count[0..last].sort[last/2]
    end
    def exceed_median? tolerance=CFG.analyzer.tolerance
      violate = (median+1)*tolerance
      node_count[@median_of..-1].all? { |e| e > violate }
    end
    def node_count
      @array.map { |nodes| nodes.size }
    end
    def exceeding_nodes
      exceed = @array[@median_of..-1].inject :&
      exceed - @array[0..@median_of-1].flatten.uniq
    end
  end

end
end
