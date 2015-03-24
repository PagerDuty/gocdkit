module Gocdkit
  class Client

    # Methods for the Materials API
    #
    # @see http://www.go.cd/documentation/user/current/api/materials_api.html
    module Materials

      # List all materials
      #
      # @return [Array<Sawyer::Resource>] list of materials
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#config-listing-api
      def materials(options = {})
        get "config/materials", options
      end

      # Notifies Go that a commit has been made to a material/repository and trigger relevant pipelines
      # Requires an authenticated admin user if the go-server has security enabled.
      #
      # Note: When using this feature, uncheck 'Poll for new changes' or set 'autoUpdate' in
      # cruise config to 'false' for the relevant materials
      #
      #--
      # For whatever reason these endpoints always return 200!
      # Even when they have malformed data! *RAGE*
      #++
      #
      # @param scm [String] svn or git
      # @param material_id [String] subversion repository UUID or git resource URL
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#notification-api
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#subversion
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#git
      def notify_material_change(scm, material_id, options = {})
        options.merge! :repository_url => material_id if scm == 'git'
        options.merge! :svn_uuid => material_id if scm == 'svn'
        options[:accept] = 'text/plain'
        post "material/notify/#{scm}", options
      end

      # List Material modifications in reverse chronological order
      # The api returns paginated results of 10 items.
      #
      # TODO: implement automatic pagination
      #
      # @param material_fingerprint [String] material fingerprints available from {#materials}
      # @return [Sawyer::Resource]
      # @see http://www.go.cd/documentation/user/current/api/materials_api.html#modifications-api
      def material_modification_history(material_fingerprint, offset = 0, options = {})
        get "materials/#{material_fingerprint}/modifications/#{offset}", options
      end

    end
  end
end
