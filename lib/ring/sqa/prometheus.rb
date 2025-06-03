require 'webrick'
require 'prometheus/client'
require 'prometheus/client/formats/text'
require "webrick"
require "webrick/accesslog"

module Ring
class SQA

  class Prometheus
    STATE_METRIC_NAME = :nlnog_ring_sqa_node_state
    LATENCY_METRIC_NAME = :nlnog_ring_sqa_node_latency_microseconds
    NODE_LAST_CHECKED_METRIC_NAME = :nlnog_ring_sqa_node_last_checked_timestamp_seconds

    def add records
      host = @hostname.split(".").first
      node =  @nodes.all

      records.each do |record|
        nodename = nodecc = node[record.peer][:name].split(".").first
        nodecc = node[record.peer][:cc].downcase
        nodestatus = record.result
        if nodestatus == "ok"
          nodeup = 1
          nodelatency = record.latency
        else
          nodeup = 0
          nodelatency = -1
        end

        labels = {
          address_family: CFG.afi,
          country_code: nodecc,
          ring_source: host,
          ring_target: nodename,
          target_status: nodestatus
        }

        @state_metric.set(nodeup, labels: labels)
        @latency_metric.set(nodelatency, labels: labels)
        @refreshed_metric.set(record.time, labels: labels)
      end
    end

    private

    def initialize nodes
      bind = CFG.prometheus.bind? || "127.0.0.1"
      port = CFG.prometheus.port? || 8129
      @hostname = Ring::SQA::CFG.host.name
      @nodes = nodes

      common_labels = [
        :address_family,
        :country_code,
        :ring_source,
        :ring_target,
        :target_status,
      ]

      @registry = ::Prometheus::Client.registry
      @state_metric = ::Prometheus::Client::Gauge.new(STATE_METRIC_NAME, docstring: "State of NLNOG Ring Node: 0 is down, 1 is up.", labels: common_labels)
      @latency_metric = ::Prometheus::Client::Gauge.new(LATENCY_METRIC_NAME, docstring: "Latency of NLNOG Ring Node in microseconds.", labels: common_labels)
      @refreshed_metric = ::Prometheus::Client::Gauge.new(NODE_LAST_CHECKED_METRIC_NAME, docstring: "Last timestamp this NLNOG Ring Node was checked.", labels: common_labels)

      @registry.register(@state_metric)
      @registry.register(@latency_metric)
      @registry.register(@refreshed_metric)


      accesslog = []
      if CFG.prometheus.accesslog?
        accesslog = [
          [AccessLog, WEBrick::AccessLog::COMMON_LOG_FORMAT]
        ]
      end
      @server =
        WEBrick::HTTPServer.new(
          Port: port,
          BindAddress: bind,
          Logger: Log,
          AccessLog: accesslog
        )
      start
    end

    def start
      @server.mount_proc "/" do |req, res|
        res["Content-Type"] = "text/plain; charset=utf-8"
        if req.path == "/metrics"
          res.status = 200
          res.body = export_metrics
        else
          res.status = 404
          res.body = "Not Found"
        end
      end

      @runner ||=
        Thread.start do
          begin
            @server.start
          rescue => e
            Log.error "Failed to start prometheus metrics web on port #{@port}: #{e}"
          end
        end
    end

    def export_metrics
      ::Prometheus::Client::Formats::Text.marshal(@registry)
    end
  end

end
end
