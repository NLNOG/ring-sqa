module Ring
class SQA

  class Poller
    PORT         = 'ring'.to_i(36)/100
    MAX_READ     = 500
    BIND_ADDRESS = CFG[:address]
  end

end
end

require_relative 'poller/sender'
require_relative 'poller/receiver'
require_relative 'poller/responder'

