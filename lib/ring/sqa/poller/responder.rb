module Ring
class SQA

  class Responder < Poller
    BIND_ADDRESS = CFG[:address]
    def run
      udp = UDPSocket.new
      Log.debug "Responder binding to #{BIND_ADDRESS.inspect} in port #{PORT}"
      udp.bind BIND_ADDRESS, PORT
      respond udp
    end

    private

    def initialize queue
      @queue = queue
      run
    end

    def respond udp
      loop do
        data, far_end = udp.recvfrom MAX_READ
        udp.send data, 0, far_end[3], PORT+1
        Log.debug "Sent response '#{data}' to '#{far_end[3]}'"
      end
    end

  end

end
end
