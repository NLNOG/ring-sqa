require_relative 'alarm/email'
require_relative 'alarm/cfg'

module Ring
class SQA

  class Alarm
    def set alarm_buffer
      if @alarm == false
        @alarm = true
        exceeding_nodes = alarm_buffer.exceeding_nodes.join ', '
        msg = "Raising alarm, nodes #{exceeding_nodes} became unreachable"
        Log.info msg
        @methods.each { |alarm_method| alarm_method.send msg }
      end
    end

    def clear
      if @alarm == true
        @alarm = false
        msg = 'Clearing alarm'
        Log.info msg
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
  end

end
end
