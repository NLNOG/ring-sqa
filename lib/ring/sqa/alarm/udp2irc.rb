module Ring
class SQA
class Alarm

  class UDP2IRC
    def send message, targets=CFG.irc.target
      url = Paste.add message[:long]
      [targets].flatten.each do |target|
        msg = [@password, target, message[:short], url].join ' '
        msg += "\0" while msg.size % 16 > 0
        UDPSocket.new.send msg, 0, @host, @port.to_i
      end
    rescue => error
      Log.error "UDP2IRC raised '#{error.class}' with message '#{error.message}'"
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
