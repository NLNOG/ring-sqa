require_relative 'alarm/email'
require_relative 'alarm/cfg'
require_relative 'mtr'
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
        msg = { short: 'Clearing alarm' }
        Log.info msg[:short]
        @methods.each { |alarm_method| alarm_method.send msg }
      end
    end

    private

    def initialize database
      @db      = database
      @methods = []
      if CFG.email.to?
        @methods << Email.new
      end
      @alarm  = false
    end

    def compose_message alarm_buffer
      msg = {short: 'Raising alarm'}
      exceeding_nodes = alarm_buffer.exceeding_nodes
      nodes = NodesJSON.new

      nodes_list = ''
      exceeding_nodes.each do |node|
        json = nodes.get node
        nodes_list << "- %-30s %14s AS%5s %2s\n" % [json['hostname'], node, json['asn'], json['countrycode']]
      end

      mtr_list = ''
      exceeding_nodes.sample(3).each do |node|
        json = nodes.get node
        mtr_list << "%-30s AS%5s (%2s)\n" % [json['hostname'], json['asn'], json['countrycode']]
        mtr_list << MTR.run(node)
        mtr_list << "\n"
      end

      buffer_list = ''
      time = 29
      alarm_buffer.array[0..28].each do |ary|
        buffer_list << "%2s min ago %3s measurement failed\n" % [time, ary.size]
        time -= 1
      end
      buffer_list <<   "  right now %3s measurement failed\n" % [alarm_buffer.array[29].size]

      msg[:long] = <<EOF
This is an automated alert from the distributed partial outage monitoring system "RING SQA".

At #{Time.now.utc} the following measurements were analysed as indicating that there is a high probability your NLNOG RING node cannot reach the entire internet. Possible causes could be an outage in your upstream's or peer's network.

The following nodes previously were reachable, but became unreachable over the course of the last 3 minutes:

#{nodes_list}

As a debug starting point 3 traceroutes were launched right after detecting the event, they might assist in pinpointing what broke:

#{mtr_list}

An alarm is raised under the following conditions: every 30 seconds your node pings all other nodes. The amount of nodes that cannot be reached is stored in a circular buffer, with each element representing a minute of measurements. In the event that the last three minutes are #{Ring::SQA::CFG.analyzer.tolerance} above the median of the previous 27 measurement slots, a partial outage is assumed. The ring buffer's output is as following:

#{buffer_list}

Kind regards,

NLNOG RING
EOF
      msg
    end

  end

end
end
