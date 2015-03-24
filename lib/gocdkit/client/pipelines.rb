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
      # Note: The Api should likely be providing this, we're doing too much work here
      #
      # @param pipeline_name [String] Pipeline name
      # @return [Sawyer::Resource] Pipeline
      def pipeline(pipeline_name, options = {})
        pipelines.each do |pipeline|
          return pipeline if pipeline[:name] == pipeline_name
        end
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
      # if the go-server has security enabled.
      #
      #--
      # Dear Gocd devs,
      #   Why the hell are we posting form-urlencoded data to a *.json endpoint??
      # Signed,
      # Frustrated
      #++
      #
      # @param pipeline_name [String]
      # @param scm [String] Either svn, git, hg, p4 or tfs
      # @param options [Hash] pipeline information
      # @option options [String] :pipelineGroup Name of the Pipeline Group to add the pipeline to. Will be created if it does not already exist.
      # @option options [String] :builder Can be `ant`, `nant`, `rake` or `exec`.
      # @option options [String] :buildfile Cannot be used with exec. example, `build.xml`
      # @option options [String] :target Cannot be used with exec. example, `all`
      # @option options [String] :command Required with exec. example, `unittest.sh arg1 arg2`
      # @option options [String] :source example, `pkg`
      # @option options [String] :dest example, `installer`
      # @option options [String] :username scm username. For use with svn, p4 and tfs repositories.
      # @option options [String] :password scm password. For use with svn, p4 and tfs repositories.
      # @option options [String] :useTickets `true` or `false`. For use with p4 repositories only.
      # @option options [String] :view Required for p4 repositories. example, `//depot/... //something/...`
      # @option options [String] :domain Domain name that given user belongs to. For use with tfs repositories only.
      # @option options [String] :projectPath Required for tfs repositories. example, `$/MyProject`
      # @see http://www.go.cd/documentation/user/current/api/configuration_api.html#adding-a-new-pipeline
      def create_pipeline(pipeline_name, scm, url, options = {})
        options.merge! :scm => scm
        options.merge! :url => url
        options.merge! :form_encode => true # UGH whyyyyyyyy.
        post "/go/tab/admin/pipelines/#{pipeline_name}.json", options
      end

    end
  end
end
