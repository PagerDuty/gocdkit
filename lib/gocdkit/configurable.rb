module Gocdkit

  # Configuration options for {Client}, defaulting to values
  # in {Default}
  module Configurable
    # @!attribute api_endpoint
    #   @return [String] Base URL for API requests. default: http://localhost:8153/go/api/
    # @!attribute default_media_type
    #   @return [String] Configure preferred media type (for API versioning, for example)
    # @!attribute connection_options
    #   @see https://github.com/lostisland/faraday
    #   @return [Hash] Configure connection options for Faraday
    # @!attribute login
    #   @return [String] go-server username for Basic HTTP Authentication
    # @!attribute middleware
    #   @see https://github.com/lostisland/faraday
    #   @return [Faraday::Builder or Faraday::RackBuilder] Configure middleware for Faraday
    # @!attribute netrc
    #   @return [Boolean] Instruct Gocdkit to get credentials from .netrc file
    # @!attribute netrc_file
    #   @return [String] Path to .netrc file. default: ~/.netrc
    # @!attribute [w] password
    #   @return [String] go-server password for Basic HTTP Authentication
    # @!attribute proxy
    #   @see https://github.com/lostisland/faraday
    #   @return [String] URI for proxy server
    # @!attribute user_agent
    #   @return [String] Configure User-Agent header for requests.
    # @!attribute web_endpoint
    #   @return [String] Base URL for web URLs. default: https://localhost:8135/go/

    attr_accessor :default_media_type, :connection_options,
                  :middleware, :netrc, :netrc_file,
                  :proxy, :user_agent
    attr_writer :password, :web_endpoint, :api_endpoint, :login

    class << self

      # List of configurable keys for {Gocdkit::Client}
      # @return [Array] of option keys
      def keys
        @keys ||= [
          :api_endpoint,
          :connection_options,
          :default_media_type,
          :login,
          :middleware,
          :netrc,
          :netrc_file,
          :password,
          :proxy,
          :user_agent,
          :web_endpoint
        ]
      end
    end

    # Set configuration options using a block
    def configure
      yield self
    end

    # Reset configuration options to default values
    def reset!
      Gocdkit::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Gocdkit::Default.options[key])
      end
      self
    end
    alias setup reset!

    def api_endpoint
      File.join(@api_endpoint, "")
    end

    # Base URL for generated web URLs
    #
    # @return [String] Default: https://github.com/
    def web_endpoint
      File.join(@web_endpoint, "")
    end

    def login
      @login
    end

    def netrc?
      !!@netrc
    end

    private

    def options
      Hash[Gocdkit::Configurable.keys.map{|key| [key, instance_variable_get(:"@#{key}")]}]
    end
  end
end
