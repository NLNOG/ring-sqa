require 'graphite-api'

module Ring
class SQA

  class Graphite
    def add records
      records.each do |record|
        hash = {
         "#{record.peer}.state" => record.result
        }
        if record.result == 'success'
          hash["#{record.peer}.latency"] = record.latency
        end
        client.metrics hash, record.time
      end
    end

    private

    def initialize server=CFG.graphite
      @client = GraphiteAPI.new graphite: server
    end
  end

end
end
