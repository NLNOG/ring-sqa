require 'json'

module Ring
class SQA

  class NodesJSON
    def get node
      (@nodes[node] or {})
    rescue
      {}
    end

    private

    def initialize
      @file = CFG.nodes_json
      @nodes = (load_json rescue {})
    end

    def load_json
      nodes = {}
      json = JSON.load File.read(@file)
      json['results']['nodes'].each do |node|
        addr = CFG.ipv6? ? node['ipv6'] : node['ipv4']
        nodes[addr] = node
      end
      nodes
    end
  end

end
end
