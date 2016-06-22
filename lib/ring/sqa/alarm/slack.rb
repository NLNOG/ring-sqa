require 'net/http'
require 'timeout'

module Ring
class SQA
class Alarm

  class Slack
    TIMEOUT = 10
    def send opts
      short, long = opts[:short], opts[:long]
      cfg  = CFG.slack
      json = JSON.pretty_generate(
        {
          "attachments" => [
            {
              "fallback"    => short,
              "pretext"     => short,
              "author_name" => "NLNog Ring SQA",
              "author_link" => "https://ring.nlnog.net/news/2014/07/new-monitoring-tool-ring-sqa/",
              "text"        => long,
            },
          ],
        },
      )
      post json, cfg.url
    rescue => error
      Log.error "Slack send raised '#{error.class}' with message '#{error.message}'"
    end

    private

    def post json, url
      Thread.new do
        begin
          Timeout::timeout(TIMEOUT) do
            uri = URI.parse url
            http = Net::HTTP.new uri.host, uri.port
            http.use_ssl = true if uri.scheme == 'https'
            req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
            req.body = json
            _response = http.request req
          end
        rescue Timeout::Error
          Log.error "Slack post timed out"
        rescue => error
          Log.error "Slack post raised '#{error.class}' with message '#{error.message}'"
        end
      end
    end
  end

end
end
end
