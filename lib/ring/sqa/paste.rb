require 'curb'
require 'timeout'

module Ring
class SQA

  class Paste
    def self.add string
      Paste.new.add string
    end
    
    def add string 
      url = CFG.paste.url
      paste string, url
    end

    private

    def paste string, url
      http = Curl::Easy.http_post(url,
                                  Curl::PostField.content('ttl', '604800'),
                                  Curl::PostField.content('content', string)) do |curl|
          curl.follow_location = true
          curl.timeout = 10
      end
      http.last_effective_url
    end
  end
end
end
