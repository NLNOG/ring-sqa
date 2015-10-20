require 'graphite-api'

module Ring
class SQA

  class Graphite
    ROOT = "nlnog.ring_sqa.#{CFG.afi}"

    def add records
      records.each do |record|
        hash = {
         "#{ROOT}.#{record.peer}.state" => record.result
        }
        if record.result == 'success'
          hash["#{ROOT}.#{record.peer}.latency"] = record.latency
        end
        @client.metrics hash, record.time
      end
    end

    private

    def initialize server=CFG.graphite
      @client = GraphiteAPI.new graphite: server
    end
  end

end
end
