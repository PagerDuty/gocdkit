module Gocdkit
  class Client

    # Methods for the Artifacts API
    #
    # TODO: This set of api calls is currently incomplete
    #
    # @see http://www.go.cd/documentation/user/current/api/artifacts_api.html
    module Artifacts

      # List all files for the particular pipeline/stage/job
      # --
      # ewww
      # ++
      #
      # @param pipeline_name [String]
      # @param pipeline_counter [Integer]
      # @param stage_name [String]
      # @param stage_counter [Integer]
      # @param job_name [String]
      # @return [Array<Sawyer::Resource>]
      # @see http://www.go.cd/documentation/user/current/api/artifacts_api.html#list
      def list_artifacts(pipeline_name, pipeline_counter, stage_name, stage_counter, job_name, options = {})
        get "files/#{pipeline_name}/#{pipeline_counter}/#{stage_name}/#{stage_counter}/#{job_name}.json", options
      end

      # Download an artifact from the go-server
      #
      # TODO: This is not implemented yet
      #
      # @param pipeline_name [String]
      # @param pipeline_counter [Integer]
      # @param stage_name [String]
      # @param stage_counter [Integer]
      # @param job_name [String]
      # @return [This should be a file]
      # @see http://www.go.cd/documentation/user/current/api/artifacts_api.html#show
      def download_artifact(pipeline_name, pipeline_counter, stage_name, stage_counter, job_name, file_path, options = {})
        fail 'Not Implemented'
        get "files/#{pipeline_name}/#{pipeline_counter}/#{stage_name}/#{stage_counter}/#{job_name}/#{file_path}", options
      end


      # upload an artifact to the go-server
      #
      # TODO: This is not implemented yet
      #   This will be a POST with either binary or text data
      #
      # @param pipeline_name [String]
      # @param pipeline_counter [Integer]
      # @param stage_name [String]
      # @param stage_counter [Integer]
      # @param job_name [String]
      # @param data [Some Data]
      #
      # @see http://www.go.cd/documentation/user/current/api/artifacts_api.html#create--append
      def create_artifact(pipeline_name, pipeline_counter, stage_name, stage_counter, job_name, file_path, data, options = {})
        fail 'Not Implemented'
      end

      # append to an existing artifact on the go-server
      #
      # TODO: This is not implemented yet
      #   This will be a PUT with text data
      #
      # @param pipeline_name [String]
      # @param pipeline_counter [Integer]
      # @param stage_name [String]
      # @param stage_counter [Integer]
      # @param job_name [String]
      # @param data [Some Data]
      #
      # @see http://www.go.cd/documentation/user/current/api/artifacts_api.html#create--append
      def append_to_artifact(pipeline_name, pipeline_counter, stage_name, stage_counter, job_name, file_path, data, options = {})
        fail 'Not Implemented'
      end
    end
  end
end
