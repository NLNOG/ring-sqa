require 'net/http'
require 'timeout'

module Ring
class SQA
class Alarm

  class Collector
    URL     = 'http://sqa-collector.infra.ring.nlnog.net/'
    TIMEOUT = 10
    def send opts
      json = JSON.pretty_generate( {
        :alarm_buffer => opts[:alarm_buffer].exceeding_nodes,
        :nodes        => opts[:nodes].all,
        :short        => opts[:short],
        :long         => opts[:long],
        :status       => opts[:status],
        :afi          => opts[:afi],
      })
      post json
    rescue => error
      Log.error "Post raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def post json
      Thread.new do
        begin
          Timeout::timeout(TIMEOUT) do
            uri = URI.parse URL
            http = Net::HTTP.new uri.host, uri.port
            http.use_ssl = true if uri.scheme == 'https'
            http.post uri.path, json
          end
        rescue Timeout::Error
          Log.error "Post timed out"
        end
      end
    end
  end

end
end
end
