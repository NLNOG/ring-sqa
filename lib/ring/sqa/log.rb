# frozen_string_literal: true

module Ring
  class SQA
    if CFG.debug?
      require 'logger'
      Log = Logger.new $stderr
    else
      begin
        require 'syslog/logger'
        Log = Syslog::Logger.new format('ring-sqad%i', (CFG.afi == 'ipv6' ? 6 : 4))
      rescue LoadError
        require 'logger'
        Log = Logger.new $stderr
      end
    end
  end
end
