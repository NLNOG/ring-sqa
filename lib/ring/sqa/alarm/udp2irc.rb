module Ring
class SQA
class Alarm

  class UDP2IRC
    def send message, irc=CFG.irc
      url = Paste.add message[:long]
      if irc.class == Array
        irc.each do |target|
          udp2irc target['password'], target['target'], message, url, target['host'], target['port']
        end
      else
        udp2irc irc.password, irc.target, message, url, irc.host, irc.port
      end
    rescue => error
      Log.error "UDP2IRC raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def udp2irc password, target, message, url, host, port
      msg = [password, target, message, url].join ' '
      msg += "\0" while msg.size % 16 > 0
      UDPSocket.new send msg, 0, host, port
    end
  end

end
end
end
