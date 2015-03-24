module Gocdkit
  class Client

    # Methods for the Stages API
    #
    # Note: These Stage API calls require a pipeline object and should likely
    #   live under pipelines/[pipeline]/stages/[stage]. If and when these api calls
    #   get pushed under the pipelines uri, these methods should be moved to the
    #   Pipelines module or to a PipelineStages module. #opinions_and_things
    #
    # @see http://www.go.cd/documentation/user/current/api/stages_api.html
    module Stages

      # Cancel an active stage of a pipeline
      #
      # @param pipeline_name [String] name of a pipeline
      # @param stage_name [String] name of the stange to cancel
      # @see http://www.go.cd/documentation/user/current/api/stages_api.html#stage-cancellation-api
      def stage_cancel(pipeline_name, stage_name, options = {})
        options[:accept] = 'text/plain' # :(
        post "stages/#{pipeline_name}/#{stage_name}/cancel", options
      end

      # Lists stage history in reverse chronological order.
      # The api returns paginated results of 10 items.
      #
      # TODO: implement automatic pagination
      #
      # @param pipeline_name [String]
      # @param stage_name [String]
      # @param offset [Integer]
      # @return [Sawyer::Resource]
      # @see http://www.go.cd/documentation/user/current/api/stages_api.html#stage-history
      def stage_history(pipeline_name, stage_name, offset = 0, options = {})
        get "stages/#{pipeline_name}/#{stage_name}/history/#{offset}", options
      end
    end
  end
end
