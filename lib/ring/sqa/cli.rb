# frozen_string_literal: true

require 'English'
require 'slop'
require 'ring/sqa'

module Ring
  class SQA
    class CLI
      attr_reader :opts

      def run
        pid = $PROCESS_ID
        puts "Running as pid: #{pid}"
        Process.daemon if @opts.daemonize?
        SQA.new
      rescue Exception => e
        crash e
        raise
      end

      private

      def initialize
        _args, @opts = opts_parse
        CFG.debug = @opts.debug?
        CFG.afi = @opts.ipv6? ? 'ipv6' : 'ipv4'
        CFG.fake = @opts.fake?
        require_relative 'log'
        Log.level = Logger::DEBUG if @opts.debug?
        run
      end

      def opts_parse
        slop = Slop.new(help: true) do
          banner 'Usage: ring-sqad [options]'
          on 'd', '--debug', 'turn on debugging'
          on '6', '--ipv6',  'use ipv6 instead of ipv4'
          on '--fake',       'initialize analyzebuffer with 0 nodes'
          on '--daemonize',  'run in background'
        end
        [slop.parse!, slop]
      end

      def crash(error)
        file = File.join '/tmp', "ring-sqa-crash.txt.#{$PROCESS_ID}"
        open file, 'w' do |file|
          file.puts "#{error.class} => #{error.message}"
          file.puts '-' * 70
          file.puts error.backtrace
          file.puts '-' * 70
        end
      end
    end
  end
end
