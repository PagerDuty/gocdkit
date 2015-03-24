module Gocdkit
  class Client

    # Admin API Methods
    #
    # Note: These methods require an authenticated admin user
    module Admin

      # Trigger a go-server backup
      # @see http://www.go.cd/documentation/user/current/api/backup_api.html#trigger-backup
      def start_backup(options = {})
        post "admin/start_backup", options
      end

      # Reload go-server command repository cache
      #
      # @see http://www.go.cd/documentation/user/current/api/command_repo_api.html#reload
      def reload_command_repo_cache(options = {})
        post "admin/command-repo-cache/reload", options
      end
    end
  end
end
