module Gocdkit
  class Client

    # Methods for the Users API
    #
    # Note: These methods require an authenticated admin user
    #
    # @see http://www.go.cd/documentation/user/current/api/users_api.html
    module Users

      # delete a disabled user
      #
      # @param user_name [String] a go-server user
      # @see http://www.go.cd/documentation/user/current/api/users_api.html#delete
      def delete_user(user_name, options = {})
        delete "users/#{username}", options
      end

    end
  end
end
