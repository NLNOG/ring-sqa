require 'slop'
require 'ring/sqa'

module Ring
class SQA

  class CLI
    attr_reader :opts

    def run
      pid = $$
      puts "Running as pid: #{pid}"
      Process.daemon if @opts.daemonize?
      SQA.new
    rescue => error
      crash error
      raise
    end

    private

    def initialize
      _args, @opts = opts_parse
      CFG.debug = @opts.debug?
      CFG.ipv6  = @opts.ipv6?
      require_relative 'log'
      Log.level = Logger::DEBUG if @opts.debug?
      run
    end

    def opts_parse
      slop = Slop.new(:help=>true) do
        banner 'Usage: ring-sqad [options]'
        on 'd', '--debug', 'turn on debugging'
        on '6', '--ipv6',  'use ipv6 instead of ipv4'
        on '--daemonize',  'run in background'
      end
      [slop.parse!, slop]
    end

    def crash error
      file = File.join CFG.directory, 'crash.txt'
      open file, 'w' do |file|
        file.puts error.class.to_s + ' => ' + error.message
        file.puts '-' * 70
        file.puts error.backtrace
        file.puts '-' * 70
      end
    end

  end

end
end

