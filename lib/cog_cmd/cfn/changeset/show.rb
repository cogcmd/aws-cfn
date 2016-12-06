require 'cfn/command'
require 'cog_cmd/cfn/changeset'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class Show < Cfn::Command

    attr_reader :changeset_name, :stack_name

    def initialize
      @changeset_name = request.args[0]
      @stack_name = request.args[1]
    end

    def run_command
      raise(Cog::Abort, "You must specify the change set name.") unless changeset_name
      raise(Cog::Abort, "You must specify stack name.") unless stack_name

      response.template = 'changeset_show'
      response.content = cfn_client.describe_change_set(
        change_set_name: @changeset_name,
        stack_name: @stack_name
      )
    end
  end
end
