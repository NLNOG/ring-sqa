module Ring
class SQA

  if CFG.debug?
    require 'logger'
    Log = Logger.new STDERR
  else
    begin
      require 'syslog/logger'
      Log = Syslog::Logger.new 'ring-sqad'
    rescue LoadError
      require 'logger'
      Log = Logger.new STDERR
    end
  end

end
end
