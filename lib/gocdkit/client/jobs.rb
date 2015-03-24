module Gocdkit
  class Client

    # Methods for the Jobs API
    #
    #
    # @see http://www.go.cd/documentation/user/current/api/job_api.html
    module Jobs

      # List of all the current job instances which are scheduled but not yet assigned to any agent.
      #
      # Note: This endpoint returns XML and so is a departure from the rest of this library.
      #
      # @return [Array<Hash>] list of scheduled jobs
      # @see http://www.go.cd/documentation/user/current/api/job_api.html#scheduled-jobs
      def scheduled_jobs(options = {})
        options[:accept] = 'application/xml' # *sigh*
        data = get "jobs/scheduled.xml", options
        job = XmlSimple.xml_in data
        job['job'] ? job['job'] : {}
      end

      # Lists stage history in reverse chronological order.
      # The api returns paginated results of 10 items.
      #
      # Note: This Job History API call requires a pipeline and stage so should likely
      #   live under pipelines/[pipeline]/stages/[stage]/jobs/[job]. If and when this api call
      #   get pushed under the pipelines uri, this method should be moved accordingly
      #
      # TODO: implement automatic pagination
      #
      # @param pipeline_name [String]
      # @param stage_name [String]
      # @param job_name
      # @param offset [Integer]
      # @return [Sawyer::Resource]
      # @see http://www.go.cd/documentation/user/current/api/job_api.html#job-history
      def stage_history(pipeline_name, stage_name, job_name, offset = 0, options = {})
        get "jobs/#{pipeline_name}/#{stage_name}/history/#{offset}", options
      end
    end
  end
end
