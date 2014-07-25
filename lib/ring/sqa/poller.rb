module Ring
class SQA

  class Poller
    MAX_READ     = 500

    def address
      #CFG.ipv6? ? CFG.host.ipv6 : CFG.host.ipv4
      CFG:ipv6? ? '::0' : '0.0.0.0' # NAT 1:1 does not have expected address where we can bind
    end

    def port
      CFG.port.to_i
    end

    def udp_socket
      CFG.ipv6? ? UDPSocket.new(Socket::AF_INET6) : UDPSocket.new
    end
  end


end
end

require_relative 'poller/sender'
require_relative 'poller/receiver'
require_relative 'poller/responder'

