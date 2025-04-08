# frozen_string_literal: true

# Configuration management for Ring SQA system
# Handles loading and management of system configuration

require 'asetus'

module Ring
  class SQA
    # Default configuration directory
    Directory = '/etc/ring-sqa'

    # Custom error classes for configuration issues
    class InvalidConfig < StandardError; end
    class NoConfig < StandardError; end

    # Initialize configuration objects
    Config = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'main.conf'
    hosts  = Asetus.new name: 'sqa', load: false, usrdir: Directory, cfgfile: 'hosts.conf'

    # Set default configuration values
    Config.default.directory          = Directory
    Config.default.debug              = false
    Config.default.port               = 'ring'.to_i(36) / 100
    Config.default.analyzer.tolerance.relative = 1.2
    Config.default.analyzer.tolerance.absolute = 10
    Config.default.analyzer.size      = 30
    Config.default.analyzer.median_of = 27
    Config.default.nodes_json         = '/etc/ring/nodes.json'
    Config.default.mtr.args           = '-i0.5 -c5 -r -w -n --aslookup'
    Config.default.mtr.timeout        = 15
    Config.default.ram_database       = false
    Config.default.paste.url          = 'https://ring.nlnog.net/paste/'
    Config.default.reset_database     = false
    Config.default.vacuum_on_purge    = true

    # Set default host configuration
    hosts.default.load                = %w[ring.nlnog.net]
    hosts.default.ignore              = %w[infra.ring.nlnog.net]

    # Load configuration files
    begin
      Config.load
      hosts.load
    rescue StandardError => e
      raise InvalidConfig, "Error loading configuration: #{e.message}"
    end

    # Make configuration available globally
    CFG = Config.cfg
    CFG.hosts = hosts.cfg

    # Set host information
    CFG.host.name = Socket.gethostname
    CFG.host.ipv4 = Socket.getaddrinfo(CFG.host.name, 'echo', Socket::AF_INET)[0][3]
    CFG.host.ipv6 = Socket.getaddrinfo(CFG.host.name, 'echo', Socket::AF_INET6)[0][3]

    # Create configuration files if they don't exist
    hosts.create
    raise NoConfig, 'edit /etc/ring-sqa/main.conf' if Config.create
  end
end
