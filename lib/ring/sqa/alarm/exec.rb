module Ring
class SQA
class Alarm

  class Exec
    def send opts
      stdout = JSON.pretty_generate( {
        :alarm_buffer => opts[:alarm_buffer].exceeding_nodes,
        :nodes        => opts[:nodes].all,
        :short        => opts[:short],
        :long         => opts[:long],
        :status       => opts[:status],
        :afi          => opts[:afi],
      })
      exec stdout, CFG.exec.command, CFG.exec.arguments?
    rescue => error
      Log.error "Exec raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def exec write, cmd, args
      args = '' unless args
      args = args.split ' '
      Open3.popen3(cmd, *args) do |stdin, stdout, stderr, wait_thr|
        stdin.write write
        stdin.close
        wait_thr.join
      end
    end
  end

end
end
end
