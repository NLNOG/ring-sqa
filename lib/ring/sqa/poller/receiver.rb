require 'timeout'

module Ring
class SQA

  class Receiver < Poller

    def run
      udp = UDPSocket.new
      udp.bind BIND_ADDRESS, PORT+1
      loop { receive udp }
    end

    private

    def initialize database
      @db = database
      run
    end

    def receive udp
      data, _ = udp.recvfrom MAX_READ
      timestamp, row_id = data.split(/\s+/)
      latency = (Time.now.utc.to_f - timestamp.to_f)*1_000_000
      @db.update row_id.to_i, 'ok', latency.to_i
    end
  end

end
end
