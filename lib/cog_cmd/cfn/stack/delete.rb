require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Delete < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :stack_name

    def initialize
      # args
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name.") unless stack_name

      response.template = 'stack_show'
      response.content = delete_stack
    end

    private

    def delete_stack
      client = Aws::CloudFormation::Client.new()
      client.delete_stack(stack_name: stack_name)

      client.describe_stacks(stack_name: stack_name).stacks[0].to_h
    end

  end
end
