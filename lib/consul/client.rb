require 'consul/client/http'
require 'logger'

module Consul
  module Client
    def self.v1
      V1.new
    end

    class V1
      def http(host: "localhost", port: 8500, logger: Logger.new("/dev/null"), rpc_retries_timeout: 10)
        HTTP.new(host: host, port: port, logger: logger, rpc_retries_timeout: rpc_retries_timeout)
      end
    end
  end
end
