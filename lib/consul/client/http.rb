require 'net/http'
require 'json'
require 'logger'

module Consul
  module Client

    NotFoundException = Class.new(StandardError)
    ResponseException = Class.new(StandardError)
    RpcErrorException = Class.new(StandardError)
    TimeoutException = Class.new(StandardError)
    InavlidArgument = Class.new(StandardError)

    class HTTP
      def initialize(host:, port:, logger:)
        @host   = host
        @port   = port
        @logger = logger
      end

      def get(request_uri, recurse: false, raw: false)
        url = base_uri + request_uri
        logger.debug("GET #{url}")

        uri = URI.parse(url)
        uri.query ||= ""
        uri.query += "&recurse" if recurse
        uri.query += "&raw" if raw

        response = http_request(:get, uri)

        raw ? response.body : parse_body(response)
      end

      def exists?(request_uri)
        url = base_uri + request_uri
        logger.debug("GET #{url}")

        uri = URI.parse(url)

        begin
          response = http_request(:get, uri)
        rescue NotFoundException
          return false
        end
        return true
      end

      def mkdir(request_uri, recurse: false)
        request_uri = "/#{request_uri}/".gsub(/\/+/,'/')
        put(request_uri) unless exists?(request_uri)
        if recurse
          while File.dirname(request_uri) != "/kv"
            request_uri = File.dirname(request_uri)
            put(request_uri) unless exists?(request_uri)
          end
        end
      end

      def watch(request_uri, index: 0, wait: '60s', recurse: false)
        url = base_uri + request_uri

        uri = URI.parse(url)
        uri.query ||= ""
        uri.query += "&index=#{index}&wait=#{wait}"
        uri.query += "&recurse" if recurse

        wait_timeout = 0
        case wait
        when /^(.+)s$/
          wait_timeout = $1.to_i + 5
        when /^(.+)m$/
          wait_timeout = ($1.to_i * 60) + 5
        else
          raise InavlidArgument
        end

        while true do
          begin
            logger.debug("GET #{uri}")

            response = http_request(:get, uri, nil, wait_timeout)
            unless response['x-consul-index'].to_i == index
              return { index: response['x-consul-index'].to_i, body: parse_body(response) }
            end
          rescue RpcErrorException
            logger.warn("Got 500 while watching #{uri}")
            sleep 5
          rescue TimeoutException
            logger.warn("Got timeout while watching #{uri}")
          end
        end
      end

      def put(request_uri, data = nil)
        url = base_uri + request_uri
        logger.debug("PUT #{url}")

        uri = URI.parse(url)

        response = http_request(:put, uri, request_uri.match('^/kv/') ? data : data.to_json)

        parse_body(response)
      end

      def delete(request_uri)
        url = base_uri + request_uri
        logger.debug("DELETE #{url}")

        uri = URI.parse(url)

        begin
          response = http_request(:delete, uri)
          parse_body(response)
        rescue NotFoundException
          nil
        end
      end

      attr_accessor :logger

      protected

      def base_uri
        "http://#{@host}:#{@port}/v1"
      end

      def parse_body(response)
        JSON.parse("[#{response.body}]")[0]
      end

      def http_request(method, uri, data = nil, timeout = 60)
        method = {
          get: Net::HTTP::Get,
          put: Net::HTTP::Put,
          delete: Net::HTTP::Delete
        }.fetch(method)

        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = timeout
        request = method.new(uri.request_uri)
        request.body = data

        begin
          response = http.request(request)

          if response.code.to_i == 404
            raise NotFoundException, "#{response.code} on #{uri}"
          elsif response.code.to_i >= 500
            raise RpcErrorException, "#{response.code} on #{uri}"
          elsif response.code.to_i >= 400
            raise ResponseException, "#{response.code} on #{uri}"
          end
        rescue Net::ReadTimeout
          raise TimeoutException, "timeout on #{uri}"
        end

        response
      end
    end
  end
end
