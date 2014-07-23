module Ring
class SQA

  class Sender < Poller
    INTERVAL       = 30   # duration pinging all nodes should take
    INTER_NODE_GAP = 0.01 # delay to sleep between each node

    def run
      udp = udp_socket
      loop do
        loop_start = Time.now
        @nodes.list.each do |node|
          query node, udp
          sleep INTER_NODE_GAP
        end
        duration = Time.now-loop_start
        if duration < INTERVAL
          sleep INTERVAL-duration
        else
          Log.warn "Send loop took longer than #{INTERVAL}s"
        end
      end
      udp.close
    end

    private

    def initialize database, nodes
      @db    = database
      @nodes = nodes
      run
    end

    def query node, udp
      Log.debug "Sending query to #{node}"
      record = @db.add peer: node
      msg    = [Time.now.utc.to_f.to_s, record.id].join ' '
      udp.send msg, 0, node, port
    rescue Errno::ECONNREFUSED
      Log.warn "connection refused to '#{node}'"
      @db.update record.id, 'connection refused'
    rescue Errno::ENETUNREACH
      Log.warn "network unreachable to '#{node}'"
      @db.update record.id, 'network unreachable'
    end
  end

end
end
