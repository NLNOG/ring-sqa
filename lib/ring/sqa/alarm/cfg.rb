module Ring
class SQA

  class Alarm
    Config = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'alarm.conf'
    Config.default.email.to     = false
    Config.default.email.from   = 'foo@example.com'
    Config.default.email.prefix = false

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
