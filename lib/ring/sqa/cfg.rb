require 'asetus'

module Ring
  class SQA
    Directory = '/etc/ring-sqa'
    class InvalidConfig < StandardError; end
    class NoConfig < StandardError; end

    Config = Asetus.new name: 'sqa', load: false, usrdir: Directory
    Config.default.email.to     = false
    Config.default.email.from   = 'foo@example.com'
    Config.default.directory    = Directory
    Config.default.debug        = false
    Config.default.hosts.load   = %w( ring.nlnog.net )
    Config.default.hosts.ignore = %w( infra.ring.nlnog.net )
    Config.default.port         = 'ring'.to_i(36)/100

    begin
      Config.load
    rescue => error
      raise InvalidConfig, "Error loading configuration: #{error.message}"
    end

    CFG = Config.cfg

    CFG.bind.ipv4 = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
    CFG.bind.ipv6 = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET6)[0][3]

    raise NoConfig, 'edit /etc/ring-sqa/config' if Config.create
  end
end
