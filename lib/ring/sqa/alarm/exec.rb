module Ring
class SQA
class Alarm

  class Exec
    def send opts
      stdout = JSON.pretty_generate [
        opts[:alarm_buffer].exceeding_nodes,
        opts[:nodes],
        opts[:short],
        opts[:long],
      ]
      exec stdout, CFG.exec.command, CFG.exec.arguments?.split(' ')
    rescue => error
      Log.error "Exec raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def exec write, cmd, *args
      Popen3.popen3(cmd, *args) do |stdin, stdout, stderr, wait_thr|
        stdin.write write
        stdin.close
        wait_thr.join
      end
    end
  end

end
end
end
