require 'rb-inotify'

module Ring
class SQA

  class Nodes
    FILE   = '/etc/hosts'
    #DOMAIN = /ring.nlnog.net/
    DOMAIN = /pooper/
    attr_reader :list

    def run
      Thread.new { @inotify.run }
    end

    private

    def initialize
      # this does not follow inode, if we change inode when generating
      # /etc/hosts that needs to be added
      @list = get_list
      @inotify = INotify::Notifier.new
      @inotify.watch(FILE, :modify) { @list = get_list }
      run
    end

    def get_list
      list = []
      File.read(FILE).lines.each do |line|
        entry = line.split(/\s+/)
        next unless entry.size > 2 and entry[2].match DOMAIN
        next if entry[0] == CFG[:address]
        list << entry[0]
      end
      list.sort
    end
  end

end
end
