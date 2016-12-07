require 'cfn/command'
require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Show < Cfn::Command

    include CogCmd::Cfn::Helpers

    attr_reader :stack_name, :cog_template

    def initialize
      @stack_name = request.args[0]
      @cog_template = request.options['verbose'] ? 'stack_show_verbose' : 'stack_show'
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name.") unless stack_name

      response.template = @cog_template
      response.content = cfn_client.describe_stack(@stack_name)
    end
  end
end
