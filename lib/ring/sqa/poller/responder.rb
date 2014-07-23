module Ring
class SQA

  class Responder < Poller
    def run
      udp = udp_socket
      Log.debug "Responder binding to #{address.inspect} in port #{port}" if CFG.debug?
      udp.bind address, port
      loop { respond udp }
    end

    private

    def initialize
      run
    end

    def respond udp
      data, far_end = udp.recvfrom MAX_READ
      udp.send data, 0, far_end[3], port+1
      Log.debug "Sent response '#{data}' to '#{far_end[3]}'" if CFG.debug?
    end

  end

end
end
