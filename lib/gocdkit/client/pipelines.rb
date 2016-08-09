module Gocdkit
  class Client

    # Methods that deal with pipelines
    #
    # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html
    # @see http://www.go.cd/documentation/user/current/api/configuration_api.html#adding-a-new-pipeline
    module Pipelines

      # List pipelines for a pipeline group or all pipelines if no group provided
      # Note: The Api should likely be providing this, we're doing too much work here
      #
      # @param pipeline_group_name [String, nil]
      # @return [Array<Sawyer::Resource>] Pipelines
      def pipelines(pipeline_group_name = nil, options = {})
        pipelines = []
        pipeline_groups.each do |pipeline_group|
          if pipeline_group_name.nil?
            pipeline_group[:pipelines].each do |pipeline|
              pipelines.push pipeline
            end
          elsif pipeline_group[:name] == pipeline_group_name
            return pipeline_group[:pipelines]
          end
        end
        pipelines
      end

      # Get information about a pipeline
      #
      # @param pipeline_name [String] Pipeline name
      # @return [Sawyer::Resource] Pipeline
      def get_pipeline(pipeline_name, options = {})
        options[:accept] =  'application/vnd.go.cd.v2+json'
        get "admin/pipelines/#{pipeline_name}", options
      end

      # Get pipeline status
      #
      # @param pipeline_name [String] Pipeline name
      # @return [Sawyer::Resource] Pipeline status
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#pipeline-status
      def pipeline_status(pipeline_name, options = {})
        get "pipelines/#{pipeline_name}/status", options
      end

      # Schedule a pipeline to run
      #
      # TODO: Specify Materials
      #
      # @param pipeline_name [String] Pipeline name
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#scheduling-pipelines
      def pipeline_schedule(pipeline_name, options = {})
        options[:accept] = "text/plain" # Why is this not Json?
        post "pipelines/#{pipeline_name}/schedule", options
      end

      # Release a lock on a pipeline
      #
      # @param pipeline_name [String] Pipeline name
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#releasing-a-pipeline-lock
      def pipeline_release_lock(pipeline_name, options = {})
        options[:accept] = "text/plain" # Why is this not Json?
        post "pipelines/#{pipeline_name}/releaseLock", options
      end

      # Pause a pipeline
      #
      # @param pipeline_name [String] Pipeline name
      # @param reason [String] Reason for pausing the pipeline
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#pause-a-pipeline
      def pipeline_pause(pipeline_name, reason, options = {})
        options.merge! :pauseCause => reason
        post "pipelines/#{pipeline_name}/pause", options
      end

      # Unpause a pipeline
      #
      # @param pipeline_name [String] Pipeline name
      # @param reason [String] Reason for pausing the pipeline
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#unpause-a-pipeline
      def pipeline_unpause(pipeline_name, options = {})
        post "pipelines/#{pipeline_name}/unpause", options
      end

      # List pipeline history in reverse chronological order.
      # The api returns paginated results of 10 items.
      #
      # TODO: implement automatic pagination
      #
      # @param pipeline_name [String] Pipeline name
      # @param offset [Integer] item offset
      # @return [Sawyer::Resource]
      # @see http://www.go.cd/documentation/user/current/api/pipeline_api.html#pipeline-history
      def pipeline_history(pipeline_name, offset = 0, options = {})
        get "pipelines/#{pipeline_name}/history/#{offset}", options
      end

      # Create a new pipeline. Requires an authenticated admin user
      # if the go-server has security enabled. See docs for all available options.
      #
      # @option options [String] :name name of the pipeline. Required.
      # @option options [Array] :materials list of materials used by pipeline. List must contain at least one entry.
      # @option options [Array] :stages list of pipeline stages. List must contain at least one entry, or specify `template`.
      #
      # @see https://api.go.cd/16.7.0/#create-a-pipeline
      def create_pipeline(options = {})
        options[:accept] =  'application/vnd.go.cd.v2+json'
        post 'admin/pipelines', options
      end
    end
  end
end
