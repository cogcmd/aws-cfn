require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Show < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :stack_name

    def initialize
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name.") unless stack_name

      response.log(:info, "stack: #{describe_stacks.to_json}")

      response.template = 'stack_show'
      response.content = describe_stacks
    end

    private

    def describe_stacks
      client = Aws::CloudFormation::Client.new()
      result = client.describe_stacks(stack_name: stack_name).stacks[0].to_h

      sort_order = {
        :parameters => :parameter_key,
        :tags => :key,
        :outputs => :output_key
      }

      sort_order.keys.each do |type|
        next unless result[type]
        result[type] = result[type].sort_by { |map| map[sort_order[type]] }
      end

      result
    end

  end
end
