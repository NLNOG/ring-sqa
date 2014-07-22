require_relative 'alarm/email'
require_relative 'alarm/cfg'

module Ring
class SQA

  class Alarm
    def set
      msg = "Raising alarm"
      Log.debug msg
      @methods.each { |alarm_method| alarm_method.send msg }
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
