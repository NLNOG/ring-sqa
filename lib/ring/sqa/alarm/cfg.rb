module Ring
class SQA

  class Alarm
    Config = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'alarm.conf'
    Config.default.email.to     = false
    Config.default.email.from   = 'foo@example.com'
    Config.default.email.prefix = false
    Config.default.irc.host     = '213.136.8.179'
    Config.default.irc.port     = 5502
    Config.default.irc.password = 'shough2oChoo'
    Config.default.irc.channel  = '#ring'

    begin
      Config.load
    rescue => error
      raise InvalidConfig, "Error loading alarm.conf configuration: #{error.message}"
    end
    CFG = Config.cfg
    Config.create
  end

end
end
