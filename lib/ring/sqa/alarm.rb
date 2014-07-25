require_relative 'alarm/email'
require_relative 'alarm/udp2irc'
require_relative 'alarm/cfg'
require_relative 'mtr'
require_relative 'paste'
require_relative 'nodes_json'

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

    def initialize database
      @db       = database
      @methods  = []
      @methods  << Email.new   if CFG.email.to?
      @methods  << UDP2IRC.new if CFG.irc.password?
      @alarm    = false
      @hostname = (Socket.gethostname rescue 'anonymous')
    end

    def compose_message alarm_buffer
      exceeding_nodes = alarm_buffer.exceeding_nodes
      msg = {short: "#{@hostname}: raising alarm - #{exceeding_nodes.size} new nodes down"}
      nodes = NodesJSON.new

      nodes_list = ''
      exceeding_nodes.each do |node|
        json = nodes.get node
        nodes_list << "- %-35s %15s  AS%-6s  %2s\n" % [json['hostname'], node, json['asn'], json['countrycode']]
      end

      mtr_list = ''
      exceeding_nodes.sample(3).each do |node|
       json = nodes.get node
        mtr_list << "%-35s AS%-6s (%2s)\n" % [json['hostname'], json['asn'], json['countrycode']]
        mtr_list << MTR.run(node)
        mtr_list << "\n"
      end

      buffer_list = ''
      time = alarm_buffer.array.size-1
      alarm_buffer.array.each do |ary|
        buffer_list << "%2s min ago %3s measurements failed" % [time, ary.size/2]
        buffer_list << (time.to_i < 3 ? " (raised alarm)\n" : " (baseline)\n")
        time -= 1
      end

      msg[:long] = <<EOF
This is an automated alert from the distributed partial outage
monitoring system "RING SQA".

At #{Time.now.utc} the following measurements were analysed
as indicating that there is a high probability your NLNOG RING node
cannot reach the entire internet. Possible causes could be an outage
in your upstream's or peer's network.

The following #{exceeding_nodes.size} nodes previously were reachable, but became unreachable
over the course of the last 3 minutes:

#{nodes_list}

As a debug starting point 3 traceroutes were launched right after
detecting the event, they might assist in pinpointing what broke:

#{mtr_list}

An alarm is raised under the following conditions: every 30 seconds
your node pings all other nodes. The amount of nodes that cannot be
reached is stored in a circular buffer, with each element representing
a minute of measurements. In the event that the last three minutes are
#{Ring::SQA::CFG.analyzer.tolerance} above the median of the previous 27 measurement slots, a partial
outage is assumed. The ring buffer's output is as following:

#{buffer_list}

Kind regards,

NLNOG RING
EOF
      msg
    end

  end

end
end
