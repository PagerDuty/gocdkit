module Gocdkit
  class Client

    # Methods for the Configuration API
    #
    # Note: all calls here require an authenticated admin user
    #   should the go-server have security enabled.
    #
    # @see http://www.go.cd/documentation/user/current/api/configuration_api.html
    module Configuration

      # Fetch a list Config repository modifications.
      #
      # return [Array<Sawyer::Resource>] List of repository modifications
      def config_revisions(options = {})
        options[:content_type] = "*/*" # I have no idea why this endpoint cares about the content-type of my get request
        get 'config/revisions', options
      end

      # Fetch the current or historical version of the go-server config
      # use the md5 form the previous call to fetch historical
      #
      # Note: attempting to fetch a non-existant config will cause the server to be very unhappy
      #
      # @return [Hash] Ruby Hash view of a go-server config
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#config-listing-api
      def config(config_md5 = 'current', options = {})
        data = get "admin/config/#{config_md5}.xml", options
        XmlSimple.xml_in data
      end

      # Diff between 2 Config Repo modifications.
      #
      # commit sha's are available from the config_revisions call
      #
      # @param from_config_commit_sha [String] commitSha of a config revision
      # @param to_config_commit_sha [String] commitSha of a config revision
      # @return [String] a diff -u
      def config_diff(from_config_commit_sha, to_config_commit_sha, options = {})
        options[:content_type] = "*/*" # Again... why.
        options[:accept] = 'text/plain'
        get "config/diff/#{from_config_commit_sha}/#{to_config_commit_sha}", options
      end
    end
  end
end
