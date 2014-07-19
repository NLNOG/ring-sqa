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
    end

    private

    def initialize
      _args, @opts = opts_parse
      SQA::CFG[:debug] = @opts.debug?
      require_relative 'log'
      Log.level = Logger::DEBUG if @opts.debug?
      run
    end

    def opts_parse
      slop = Slop.new(:help=>true) do
        banner 'Usage: ring-sqad [options]'
        on 'd', '--debug', 'turn on debugging'
        on '--daemonize',  'run in background'
      end
      [slop.parse!, slop]
    end
  end

end
end

