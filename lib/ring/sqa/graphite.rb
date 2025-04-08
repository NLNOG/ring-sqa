# frozen_string_literal: true

require 'graphite-api'

module Ring
  class SQA
    class Graphite
      ROOT = "nlnog.ring_sqa.#{CFG.afi}"

      def add(records)
        host = @hostname.split('.').first
        node = @nodes.all
        records.each do |record|
          nodename = noderec = node[record.peer][:name].split('.').first
          nodecc = noderec = node[record.peer][:cc].downcase
          hash = {
            "#{ROOT}.#{host}.#{nodecc}.#{nodename}.state" => record.result
          }
          hash["#{ROOT}.#{host}.#{nodecc}.#{nodename}.latency"] = record.latency if record.result != 'no response'
          begin
            @client.metrics hash, record.time
          rescue StandardError
            Log.error 'Failed to write metrics to Graphite.'
          end
        end
      end

      private

      def initialize(nodes, server = CFG.graphite)
        @client = GraphiteAPI.new graphite: server
        @hostname = Ring::SQA::CFG.host.name
        @nodes = nodes
      end
    end
  end
end
