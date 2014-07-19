require 'timeout'

module Ring
class SQA

  class Querier < Poller
    TIMEOUT  = 1

    def run
      loop do
        @nodes.list.each do |node|
          query node
        end
        sleep 2
      end
    end

    private

    def initialize queue, database, nodes
      @queue = queue
      @db    = database
      @nodes = nodes
      run
    end

    def query node
      Log.debug "Sending query to #{node}"
      rtt    = nil
      status = 'unknown'
      udp    = UDPSocket.new
      time   = Time.now.utc
      timeout(TIMEOUT) do
        udp.bind CFG[:address], PORT+1
        udp.connect node, PORT
        udp.send Time.now.utc.to_f.to_s, 0
        data, _  = udp.recvfrom MAX_READ
        rtt = (Time.now.utc.to_f - data.to_f)*1_000_000
        status = 'ok'
      end
    rescue Timeout::Error
      status = 'timeout'
    rescue Errno::ECONNREFUSED
      status = 'connection refused'
    ensure
      udp.close
      @db.add time: time, peer: node, latency: rtt, result: status
    end
  end

end
end
