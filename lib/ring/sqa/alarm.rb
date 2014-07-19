require_relative 'alarm/email'

module Ring
class SQA

  class Alarm
    def send msg
      @alarm_methods.each do |alarm_method|
        alarm_method.send msg
      end
    end

    private

    def initialize
      email = Email.new
      @alarm_methods = [email]
    end
  end

end
end
