require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Resources < Cog::Command

    attr_reader :stack_name

    def initialize
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Error, "You must specify a stack name.") unless stack_name

      response.template = 'stack_resource_list'
      response.content = list_resources
    end

    private

    def list_resources
      client = Aws::CloudFormation::Client.new()

      client.
        list_stack_resources(stack_name: stack_name).
        stack_resource_summaries.
        map(&:to_h)
    end

  end
end
