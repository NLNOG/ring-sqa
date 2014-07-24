module Ring
class SQA
class Alarm

  class UDP2IRC
    def send message, channel=CFG.irc.channel
      msg = [@password, channel, message[:short]].join ' '
      msg += "\0" while msg.size % 16 > 0
      UDPSocket.new.send msg, 0, HOST, PORT
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
