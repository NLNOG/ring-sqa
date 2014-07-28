require_relative 'alarm/email'
require_relative 'alarm/udp2irc'
require_relative 'alarm/cfg'
require_relative 'alarm/message'
require_relative 'mtr'
require_relative 'paste'

module Ring
class SQA

  class Alarm
    def set alarm_buffer
      if @alarm == false
        @alarm = true
        msg = compose_message alarm_buffer
        Log.info msg[:short]
        @methods.each { |alarm_method| alarm_method.send msg }
      end
    end

    def clear
      if @alarm == true
        @alarm = false
        msg = { short: "#{@hostname}: clearing alarm" }
        msg[:long] = msg[:short]
        Log.info msg[:short]
        @methods.each { |alarm_method| alarm_method.send msg }
      end
    end

    private

    def initialize nodes
      @nodes    = nodes
      @methods  = []
      @methods  << Email.new   if CFG.email.to?
      @methods  << UDP2IRC.new if CFG.irc.password?
      @hostname = Ring::SQA::CFG.host.name
      @afi      = Ring::SQA::CFG.afi
      @alarm    = false
    end

    def compose_message alarm_buffer
      exceeding_nodes = alarm_buffer.exceeding_nodes
      msg = {short: "#{@hostname}: raising #{@afi} alarm - #{exceeding_nodes.size} new nodes down"}
      exceeding_nodes = exceeding_nodes.map { |node| @nodes.get node }

      addr_len = @afi == 'ipv6' ? 40 : 15
      nodes_list = ''
      exceeding_nodes.sort_by{ |node| node[:cc] }.each do |node|
        nodes_list << "- %-35s %#{addr_len}s  AS%-6s  %2s\n" % [node[:name], node[:ip], node[:as], node[:cc]]
      end

      mtr_list = ''
      exceeding_nodes.sample(3).each do |node|
        mtr_list << "%-35s AS%-6s (%2s)\n" % [node[:name], node[:as], node[:cc]]
        mtr_list << MTR.run(node[:ip])
        mtr_list << "\n"
      end

      buffer_list = ''
      time = alarm_buffer.array.size-1
      alarm_buffer.array.each do |ary|
        buffer_list << "%2s min ago %3s measurements failed" % [time, ary.size/2]
        buffer_list << (time.to_i < 3 ? " (raised alarm)\n" : " (baseline)\n")
        time -= 1
      end

      msg[:long] = message nodes_list, mtr_list, buffer_list, exceeding_nodes.size
      msg
    end

  end

end
end
