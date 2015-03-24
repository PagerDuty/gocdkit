require 'faraday'
require 'gocdkit/error'

module Gocdkit
  # Faraday response middleware
  module Response

    # This class raises an Gocdkit-flavored exception based
    # HTTP status codes returned by the API
    class RaiseError < Faraday::Response::Middleware

      private

      def on_complete(response)
        if error = Gocdkit::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
