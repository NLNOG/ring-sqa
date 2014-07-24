require 'net/http'

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
        uri = URI.parse url
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data({'content' => string,
                               'ttl' => '608400'})
        response = https.request request
        "https://" + uri.host + response['location']
    end
  end
end
end
