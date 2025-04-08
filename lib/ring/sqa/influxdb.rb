# frozen_string_literal: true

require 'influxdb-client'

module Ring
  class SQA
    class InfluxDBWriter
      ROOT = "nlnog.ring_sqa.#{CFG.afi}"

      def add(records)
        host   = @hostname.split('.').first
        node   = @nodes.all
        data   = []

        records.each do |record|
          nodename = nodecc = node[record.peer][:name].split('.').first
          nodecc = node[record.peer][:cc].downcase

          point = InfluxDB2::Point.new(name: 'ring-sqa_measurements')
                                  .add_tag('afi', CFG.afi)
                                  .add_tag('dst_node', nodename)
                                  .add_tag('dst_cc', nodecc)
                                  .add_tag('src_node', host)
                                  .add_tag('dst_lat', node[record.peer][:geo].split(',')[0])
                                  .add_tag('dst_lon', node[record.peer][:geo].split(',')[1])
                                  .add_field('latency', record.latency)
                                  .add_field('state', record.result == 'no response' ? 0 : 1)

          @write_api.write(data: point)
        rescue StandardError => e
          Log.error "Failed to write metrics to InfluxDB: #{e.message}"
        end
      end

      private

      def initialize(nodes)
        @client = InfluxDB2::Client.new(CFG.influxdb.url, CFG.influxdb.token, bucket: CFG.influxdb.bucket,
                                                                              org: CFG.influxdb.org, use_ssl: false, precision: InfluxDB2::WritePrecision::NANOSECOND)
        @write_api = @client.create_write_api  # ✅ Fix write_api issue
        @hostname = Ring::SQA::CFG.host.name
        @nodes = nodes
      end
    end
  end
end
