# frozen_string_literal: true

require 'net/http'

module Ring
  class SQA
    class Paste
      def self.add(string)
        Paste.new.add string
      rescue StandardError => e
        "paste raised '#{e.class}' with message '#{e.message}'"
      end

      def add(string, url = CFG.paste.url)
        paste string, url
      end

      private

      def paste(string, url)
        uri  = URI.parse url
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        rslt = http.post uri.path, URI.encode_www_form([['content', string], %w[ttl 604800]])
        uri.path = rslt.fetch('location')
        uri.to_s
      end
    end
  end
end
