require 'gocdkit/response/raise_error'
require 'gocdkit/response/feed_parser'
require 'gocdkit/version'

module Gocdkit

  # Default configuration options for {Client}
  module Default

    # Default API endpoint
    API_ENDPOINT = "http://localhost:8153/go/api".freeze

    # Default User Agent header string
    USER_AGENT   = "Gocdkit Ruby Gem #{Gocdkit::VERSION}".freeze

    # Default media type
    MEDIA_TYPE   = "application/json".freeze

    # Default WEB endpoint
    WEB_ENDPOINT = "https://localhost:8153/go".freeze

    # In Faraday 0.9, Faraday::Builder was renamed to Faraday::RackBuilder
    RACK_BUILDER_CLASS = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder

    # Default Faraday middleware stack
    MIDDLEWARE = RACK_BUILDER_CLASS.new do |builder|
      builder.use Gocdkit::Response::RaiseError
      builder.use Gocdkit::Response::FeedParser
      builder.adapter Faraday.default_adapter
    end

    class << self

      # Configuration options
      # @return [Hash]
      def options
        Hash[Gocdkit::Configurable.keys.map{|key| [key, send(key)]}]
      end

      # Default API endpoint from ENV or {API_ENDPOINT}
      # @return [String]
      def api_endpoint
        ENV['GOCDKIT_API_ENDPOINT'] || API_ENDPOINT
      end

      # Default options for Faraday::Connection
      # @return [Hash]
      def connection_options
        {
          :headers => {
            :accept => default_media_type,
            :user_agent => user_agent
          }
        }
      end

      # Default media type from ENV or {MEDIA_TYPE}
      # @return [String]
      def default_media_type
        ENV['GOCDKIT_DEFAULT_MEDIA_TYPE'] || MEDIA_TYPE
      end

      # Default Go-server username for Basic Auth from ENV
      # @return [String]
      def login
        ENV['GOCDKIT_LOGIN']
      end

      # Default middleware stack for Faraday::Connection
      # from {MIDDLEWARE}
      # @return [String]
      def middleware
        MIDDLEWARE
      end

      # Default go-server password for Basic Auth from ENV
      # @return [String]
      def password
        ENV['GOCDKIT_PASSWORD']
      end

      # Default proxy server URI for Faraday connection from ENV
      # @return [String]
      def proxy
        ENV['GOCDKIT_PROXY']
      end

      # Default User-Agent header string from ENV or {USER_AGENT}
      # @return [String]
      def user_agent
        ENV['GOCDKIT_USER_AGENT'] || USER_AGENT
      end

      # Default web endpoint from ENV or {WEB_ENDPOINT}
      # @return [String]
      def web_endpoint
        ENV['GOCDKIT_WEB_ENDPOINT'] || WEB_ENDPOINT
      end

      # Default behavior for reading .netrc file
      # @return [Boolean]
      def netrc
        ENV['GOCDKIT_NETRC'] || false
      end

      # Default path for .netrc file
      # @return [String]
      def netrc_file
        ENV['GOCDKIT_NETRC_FILE'] || File.join(ENV['HOME'].to_s, '.netrc')
      end

    end
  end
end
