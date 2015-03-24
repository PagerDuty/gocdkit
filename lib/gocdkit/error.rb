module Gocdkit
  # Custom error class for rescuing from all GitHub errors
  class Error < StandardError

    # Returns the appropriate Gocdkit::Error subclass based
    # on status and response message
    #
    # @param [Hash] response HTTP response
    # @return [Gocdkit::Error]
    def self.from_response(response)
      status  = response[:status].to_i
      body    = response[:body].to_s
      headers = response[:response_headers]

      if klass =  case status
                  when 400      then Gocdkit::BadRequest
                  when 401      then Gocdkit::Unauthorized
                  when 404      then Gocdkit::NotFound
                  when 406      then Gocdkit::NotAcceptable
                  when 415      then Gocdkit::UnsupportedMediaType
                  when 400..499 then Gocdkit::ClientError
                  when 500      then Gocdkit::InternalServerError
                  when 501      then Gocdkit::NotImplemented
                  when 502      then Gocdkit::BadGateway
                  when 503      then Gocdkit::ServiceUnavailable
                  when 500..599 then Gocdkit::ServerError
                  end
        klass.new(response)
      end
    end

    def initialize(response=nil)
      @response = response
      super(build_error_message)
    end

    # Documentation URL returned by the API for some errors
    # Going to leave this. This would be great!
    #
    # @return [String]
    def documentation_url
      data[:documentation_url] if data.is_a? Hash
    end

    # Array of validation errors
    # @return [Array<Hash>] Error info
    def errors
      if data && data.is_a?(Hash)
        data[:errors] || []
      else
        []
      end
    end

    private

    def data
      @data ||=
        if (body = @response[:body]) && !body.empty?
          if body.is_a?(String) &&
            @response[:response_headers] &&
            @response[:response_headers][:content_type] =~ /json/

            Sawyer::Agent.serializer.decode(body)
          else
            body
          end
        else
          nil
        end
    end

    def response_message
      case data
      when Hash
        data[:message]
      when String
        data
      end
    end

    def response_error
      "Error: #{data[:error]}" if data.is_a?(Hash) && data[:error]
    end

    def response_error_summary
      return nil unless data.is_a?(Hash) && !Array(data[:errors]).empty?

      summary = "\nError summary:\n"
      summary << data[:errors].map do |hash|
        hash.map { |k,v| "  #{k}: #{v}" }
      end.join("\n")

      summary
    end

    def build_error_message
      return nil if @response.nil?

      message =  "#{@response[:method].to_s.upcase} "
      message << redact_url(@response[:url].to_s) + ": "
      message << "#{@response[:status]} - "
      message << "#{response_message}" unless response_message.nil?
      message << "#{response_error}" unless response_error.nil?
      message << "#{response_error_summary}" unless response_error_summary.nil?
      message << " // See: #{documentation_url}" unless documentation_url.nil?
      message
    end

    def redact_url(url_string)
      %w[client_secret access_token].each do |token|
        url_string.gsub!(/#{token}=\S+/, "#{token}=(redacted)") if url_string.include? token
      end
      url_string
    end
  end

  # Raised on errors in the 400-499 range
  class ClientError < Error; end

  # Raised when GitHub returns a 400 HTTP status code
  class BadRequest < ClientError; end

  # Raised when GitHub returns a 401 HTTP status code
  class Unauthorized < ClientError; end

  # Raised when GitHub returns a 401 HTTP status code
  # and headers include "X-GitHub-OTP"
  class OneTimePasswordRequired < ClientError
    #@private
    OTP_DELIVERY_PATTERN = /required; (\w+)/i

    #@private
    def self.required_header(headers)
      OTP_DELIVERY_PATTERN.match headers['X-GitHub-OTP'].to_s
    end

    # Delivery method for the user's OTP
    #
    # @return [String]
    def password_delivery
      @password_delivery ||= delivery_method_from_header
    end

    private

    def delivery_method_from_header
      if match = self.class.required_header(@response[:response_headers])
        match[1]
      end
    end
  end

  # Raised when GitHub returns a 404 HTTP status code
  class NotFound < ClientError; end

  # Raised when GitHub returns a 406 HTTP status code
  class NotAcceptable < ClientError; end

  # Raised on errors in the 500-599 range
  class ServerError < Error; end

  # Raised when GitHub returns a 500 HTTP status code
  class InternalServerError < ServerError; end

  # Raised when GitHub returns a 501 HTTP status code
  class NotImplemented < ServerError; end

  # Raised when GitHub returns a 502 HTTP status code
  class BadGateway < ServerError; end

  # Raised when GitHub returns a 503 HTTP status code
  class ServiceUnavailable < ServerError; end

  # Raised when client fails to provide valid Content-Type
  class MissingContentType < ArgumentError; end
end
