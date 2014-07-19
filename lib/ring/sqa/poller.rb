module Ring
class SQA

  class Poller
    PORT = 'ring'.to_i(36)/100
    MAX_READ = 500

    private

    def initialize queue
      @queue = queue
    end
  end

end
end

require_relative 'poller/querier'
require_relative 'poller/responder'

