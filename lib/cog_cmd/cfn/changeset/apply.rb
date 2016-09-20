require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class Apply < Cog::Command

    attr_reader :changeset_name, :stack_name

    def initialize
      @changeset_name = request.args[0]
      @stack_name = request.args[1]
    end


    def run_command
      raise(Cog::Error, "You must specify the change set name.") unless changeset_name
      raise(Cog::Error, "You must specify stack name.") unless stack_name

      response.template = 'stack_show'
      response.content = apply_changeset
    end

    private

    def apply_changeset
      client = Aws::CloudFormation::Client.new()

      cs_params = {
        change_set_name: changeset_name,
        stack_name: stack_name
      }

      client.execute_change_set(cs_params)
      client.describe_stacks(stack_name: stack_name).stacks[0].to_h
    end

  end
end
