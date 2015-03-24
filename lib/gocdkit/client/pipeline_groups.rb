module Gocdkit
  class Client

    # Methods for the Pipeline Groups API
    module PipelineGroups

      # List all pipeline groups and associated pipelines
      #
      # @return [Array<Sawyer::Resource>] Array of Pipeline Groups
      # @see http://www.go.cd/documentation/user/current/api/pipeline_group_api.html
      def pipeline_groups(options = {})
        get "config/pipeline_groups", options
      end
    end
  end
end
