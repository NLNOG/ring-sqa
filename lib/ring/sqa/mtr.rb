require 'open3'
require 'timeout'

module Ring
class SQA

  class MTR
    BIN  = 'mtr'
    def self.run host
      MTR.new.run host
    end

    def run host, args=nil
      Timeout::timeout(@timeout) do
        args ||= CFG.mtr.args.split(' ')
        mtr host, args
      end
    rescue Timeout::Error
      "MTR runtime exceeded #{@timeout}s"
    end

    private

    def initialize timeout=CFG.mtr.timeout
      @timeout = timeout
    end

    def mtr host, *args
      out = ''
      args = [*args, host].flatten
      Open3.popen3(BIN, *args) do |stdin, stdout, stderr, wait_thr|
        out << stdout.read until stdout.eof?
      end
      'mtr ' + args.join(' ') + "\n" + out.each_line.to_a[1..-1].join rescue ''
    end
  end

end
end
