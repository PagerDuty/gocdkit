require 'sawyer'
require 'xmlsimple'
require 'gocdkit/arguments'
require 'gocdkit/authentication'
require 'gocdkit/configurable'
require 'gocdkit/client/agents'
require 'gocdkit/client/artifacts'
require 'gocdkit/client/admin'
require 'gocdkit/client/configuration'
require 'gocdkit/client/jobs'
require 'gocdkit/client/materials'
require 'gocdkit/client/pipeline_groups'
require 'gocdkit/client/pipelines'
require 'gocdkit/client/stages'
require 'gocdkit/client/users'

module Gocdkit

  # Client for the go-server API
  #
  # @see http://go.cd/documentations/user/current/api/
  class Client

    include Gocdkit::Authentication
    include Gocdkit::Configurable
    include Gocdkit::Client::Agents
    include Gocdkit::Client::Admin
    include Gocdkit::Client::Artifacts
    include Gocdkit::Client::Configuration
    include Gocdkit::Client::Jobs
    include Gocdkit::Client::Materials
    include Gocdkit::Client::PipelineGroups
    include Gocdkit::Client::Pipelines
    include Gocdkit::Client::Stages
    include Gocdkit::Client::Users

    # Header keys that can be passed in options hash to {#get},{#head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type])

    def initialize(options = {})
      # Use options passed in, but fall back to module defaults
      Gocdkit::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", options[key] || Gocdkit.instance_variable_get(:"@#{key}"))
      end

      login_from_netrc unless user_authenticated?
    end

    # Compares client options to a Hash of requested options
    #
    # @param opts [Hash] Options to compare with current client options
    # @return [Boolean]
    def same_options?(opts)
      opts.hash == options.hash
    end

    # Text representation of the client, masking tokens and passwords
    #
    # @return [String]
    def inspect
      inspected = super

      # mask password
      inspected = inspected.gsub! @password, "*******" if @password
      # Only show last 4 of token, secret
      if @access_token
        inspected = inspected.gsub! @access_token, "#{'*'*36}#{@access_token[36..-1]}"
      end
      if @client_secret
        inspected = inspected.gsub! @client_secret, "#{'*'*36}#{@client_secret[36..-1]}"
      end

      inspected
    end

    # Make a HTTP GET request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def get(url, options = {})
      request :get, url, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP POST request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def post(url, options = {})
      request :post, url, options
    end

    # Make a HTTP PUT request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def put(url, options = {})
      request :put, url, options
    end

    # Make a HTTP PATCH request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def patch(url, options = {})
      request :patch, url, options
    end

    # Make a HTTP DELETE request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def delete(url, options = {})
      request :delete, url, options
    end

    # Make a HTTP HEAD request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def head(url, options = {})
      request :head, url, parse_query_and_convenience_headers(options)
    end

    # Hypermedia agent lol
    #
    # @return [Sawyer::Agent]
    def agent

      @agent ||= Sawyer::Agent.new(api_endpoint, sawyer_options) do |http|
        http.headers[:accept] = default_media_type
        http.headers[:content_type] = "application/json"
        http.headers[:user_agent] = user_agent
        if basic_authenticated?
          http.basic_auth(@login, @password)
        end
      end
    end

    # Response for last HTTP request
    #
    # @return [Sawyer::Response]
    def last_response
      @last_response if defined? @last_response
    end

    # Set username for authentication
    #
    # @param value [String] Go-server username
    def login=(value)
      reset_agent
      @login = value
    end

    # Set password for authentication
    #
    # @param value [String] Go-server password
    def password=(value)
      reset_agent
      @password = value
    end

    # Wrapper around Kernel#warn to print warnings unless
    # GOCDIT_SILENT is set to true.
    #
    # @return [nil]
    def gocdkit_warn(*message)
      unless ENV['GOCDKIT_SILENT']
        warn message
      end
    end

    private

    def reset_agent
      @agent = nil
    end

    def request(method, path, data, options = {})
      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
        if content_type = data.delete(:content_type)
          options[:headers][:content_type] = content_type
        end
        # AUUUGHhh here is where I regret not using Faraday directly
        # The real fix here is to make a Serializer class pass it to
        # the Sawyer options...
        if data.delete(:form_encode)
          data = URI.encode_www_form(data)
          options[:headers]['Content-Type'] = 'application/x-www-form-urlencoded'
        end
      end

      @last_response = response = agent.call(method, URI::Parser.new.escape(path.to_s), data, options)
      response.data
    end

    # Executes the request, checking if it was successful
    #
    # @return [Boolean] True on success, false otherwise
    def boolean_from_response(method, path, options = {})
      request(method, path, options)
      @last_response.status == 204
    rescue Gocdkit::NotFound
      false
    end


    def sawyer_options
      opts = {
        :links_parser => Sawyer::LinkParsers::Simple.new
      }
      conn_opts = @connection_options
      conn_opts[:builder] = @middleware if @middleware
      conn_opts[:proxy] = @proxy if @proxy
      opts[:faraday] = Faraday.new(conn_opts)

      opts
    end

    def parse_query_and_convenience_headers(options)
      headers = options.fetch(:headers, {})
      CONVENIENCE_HEADERS.each do |h|
        if header = options.delete(h)
          headers[h] = header
        end
      end
      query = options.delete(:query)
      opts = {:query => options}
      opts[:query].merge!(query) if query && query.is_a?(Hash)
      opts[:headers] = headers unless headers.empty?

      opts
    end
  end
end
