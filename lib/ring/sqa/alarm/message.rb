module Ring
class SQA

  class Alarm
    def message nodes_list, mtr_list, buffer_list
"
Regarding: #{Ring::SQA::CFG.host.name}

This is an automated alert from the distributed partial outage
monitoring system 'RING SQA'.

At #{Time.now.utc} the following measurements were analysed
as indicating that there is a high probability your NLNOG RING node
cannot reach the entire internet. Possible causes could be an outage
in your upstream's or peer's network.

The following #{nodes_list.size} nodes previously were reachable, but became unreachable
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
"
    end
  end

end
end
