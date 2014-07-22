require_relative 'alarm/email'

module Ring
class SQA
  MIN_ALARM = 2

  class Alarm
    def set id, node
      last_id = @last_id[node]
      if last_id and @db.up_since?(last_id, node)
        @count[node] = 1  # not a consequtive down, restarting
      else
        @count[node] += 1 # consequtive down, incrementing count
      end
      @last_id[node] = id
      if @count[node] == MIN_ALARM
        msg = "Raising alarm for node '#{node}'"
        Log.debug msg
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
      @count   = Hash.new 0
      @last_id = Hash.new
    end
  end

end
end
