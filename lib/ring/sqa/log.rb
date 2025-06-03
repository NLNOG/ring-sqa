module Ring
class SQA

  if CFG.debug?
    require 'logger'
    Log = Logger.new STDERR
    Log.level = Logger::DEBUG
    AccessLog = Log
  else
    begin
      require 'syslog/logger'
      Log = Syslog::Logger.new 'ring-sqad%i' % ( CFG.afi == "ipv6" ? 6 : 4 )
      Log.level = Logger::INFO
      AccessLog = Logger.new STDERR
    rescue LoadError
      require 'logger'
      Log = Logger.new STDERR
      Log.level = Logger::INFO
      AccessLog = Log
    end
  end

end
end
