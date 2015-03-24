module Gocdkit
  class Client

    # Methods for the Agent API
    #
    # @see http://www.go.cd/documentation/user/current/api/agent_api.html
    module Agents

      # List of all agents of the go-server
      #
      # @return [Array<Sawyer::Resource>] list of agents
      # @see http://www.go.cd/documentation/user/current/api/agent_api.html#list-agents
      def agents(options = {})
        get "agents", options
      end

      # Enable a disabled agent or approve a pending agent.
      #
      # @param agent_uuid [String]
      # @see http://www.go.cd/documentation/user/current/api/agent_api.html#enable-agent
      def enable_agent(agent_uuid, options = {})
        post "agents/#{agent_uuid}/enable", options
      end

      # Disable an enabled/pending agent.
      #
      # @param agent_uuid [String]
      # @see http://www.go.cd/documentation/user/current/api/agent_api.html#disable-agent
      def disable_agent(agent_uuid, options = {})
        post "agents/#{agent_uuid}/disable", options
      end

      # Delete a disabled agent. Note that the agent will not be deleted unless it is in disabled state and is not building any job.
      # See the go documentation for caveats regarding the deletion of agents.
      #
      # @param agent_uuid [String]
      # @see http://www.go.cd/documentation/user/current/api/agent_api.html#delete-agent
      def delete_agent(agent_uuid, options = {})
        post "agents/#{agent_uuid}/delete", options
      end

      # List Agent Job Run history.
      #
      # @param agent_uuid [String]
      # @return [Sawyer::Resource]
      # @see http://www.go.cd/documentation/user/current/api/agent_api.html#agent-job-run-history
      def agent_job_run_history(agent_uuid, offset = 0, options = {})
        get "agents/#{agent_uuid}/job_run_history/#{offset}", options
      end

    end
  end
end
