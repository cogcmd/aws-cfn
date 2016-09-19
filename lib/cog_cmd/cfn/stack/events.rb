require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Events < Cog::Command

    include CogCmd::Cfn::Helpers

  attr_reader :stack_name

    def initialize
      # args
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Error, "You must specify a stack name.") unless stack_name

      response.template = 'stack_event_list'
      response.content = describe_events
    end

    private

    def describe_events
      client = Aws::CloudFormation::Client.new()
      client.describe_stack_events(stack_name: stack_name).stack_events.map(&:to_h)
    end
  end
end
