require_relative 'paste'

module Ring
class SQA
class Alarm

  class UDP2IRC
    def send message, channel=CFG.irc.channel
      url = Paste.add message[:long]
      msg = [@password, channel, message[:short], url].join ' '
      msg += "\0" while msg.size % 16 > 0
      UDPSocket.new.send msg, 0, @host, @port.to_i
    end

    private

    def initialize host=CFG.irc.host, port=CFG.irc.port, password=CFG.irc.password
      @host     = host
      @port     = port
      @password = password
    end
  end

end
end
end
