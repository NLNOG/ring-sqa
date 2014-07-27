module Ring
class SQA

  if CFG.debug?
    require 'logger'
    Log = Logger.new STDERR
  else
    begin
      require 'syslog/logger'
      Log = Syslog::Logger.new 'ring-sqad%i' % ( CFG.afi == "ipv6" ? 6 : 4 )
    rescue LoadError
      require 'logger'
      Log = Logger.new STDERR
    end
  end

end
end
