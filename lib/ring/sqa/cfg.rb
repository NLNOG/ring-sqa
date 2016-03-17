require 'asetus'

module Ring
  class SQA
    Directory = '/etc/ring-sqa'
    class InvalidConfig < StandardError; end
    class NoConfig < StandardError; end

    Config = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'main.conf'
    hosts  = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'hosts.conf'

    Config.default.directory          = Directory
    Config.default.debug              = false
    Config.default.port               = 'ring'.to_i(36)/100
    Config.default.analyzer.tolerance = 1.2
    Config.default.analyzer.size      = 30
    Config.default.analyzer.median_of = 27
    Config.default.nodes_json         = '/etc/ring/nodes.json'
    Config.default.mtr.args           = '-i0.5 -c5 -r -w -n --aslookup'
    Config.default.mtr.timeout        = 15
    Config.default.ram_database       = false
    Config.default.paste.url          = 'https://ring.nlnog.net/paste/'

    hosts.default.load                = %w( ring.nlnog.net )
    hosts.default.ignore              = %w( infra.ring.nlnog.net )

    begin
      Config.load
      hosts.load
    rescue => error
      raise InvalidConfig, "Error loading configuration: #{error.message}"
    end

    CFG = Config.cfg
    CFG.hosts = hosts.cfg

    CFG.host.name = Socket.gethostname
    CFG.host.ipv4 = Socket::getaddrinfo(CFG.host.name,"echo",Socket::AF_INET)[0][3]
    CFG.host.ipv6 = Socket::getaddrinfo(CFG.host.name,"echo",Socket::AF_INET6)[0][3]

    hosts.create
    raise NoConfig, 'edit /etc/ring-sqa/main.conf' if Config.create
  end
end
