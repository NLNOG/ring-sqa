require 'rb-inotify'
require 'ipaddr'

module Ring
class SQA

  class Nodes
    FILE   = '/etc/hosts'
    attr_reader :list

    def run
      Thread.new { @inotify.run }
    end

    private

    def initialize
      @list = get_list
      @inotify = INotify::Notifier.new
      @inotify.watch(File.dirname(FILE), :modify, :create) do |event|
        @list = get_list if event.name == FILE.split('/').last
      end
      run
    end

    def get_list
      Log.info "loading #{FILE}"
      list = []
      File.read(FILE).lines.each do |line|
        entry = line.split(/\s+/)
        next if entry_skip? entry
        list << entry.first
      end
      list.sort
    end

    def entry_skip? entry
      return true unless entry.size > 2
      return true if entry.first.match /^\s*#/
      return true if CFG.hosts.ignore.any?   { |re| entry[2].match Regexp.new(re) }
      return true unless CFG.hosts.load.any? { |re| entry[2].match Regexp.new(re) }

      address = IPAddr.new(entry.first) rescue (return true)
      if CFG.ipv6?
        return true if address.ipv4?
        return true if address == IPAddr.new(CFG.bind.ipv6)
      else
        return true if address.ipv6?
        return true if address == IPAddr.new(CFG.bind.ipv4)
      end
      false
    end

  end

end
end
