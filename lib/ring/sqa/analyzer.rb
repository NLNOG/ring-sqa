require_relative 'alarm'

module Ring
class SQA

  class Analyzer
    def run
      loop do
        sleep 10
        Log.debug "Analyzer loop at end"
      end
    end

    private

    def initialize database
      @db = database
      @alarm = Alarm.new
    end
  end

end
end
