require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class List < Cog::Command

    attr_reader :stack_name

    def initialize
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Abort, "You must specify the stack name.") unless stack_name

      response.template = 'changeset_list'
      response.content = list_change_sets
    end

    private

    def list_change_sets
      client = Aws::CloudFormation::Client.new()

      client.
        list_change_sets({ stack_name: stack_name }).
        summaries.
        map(&:to_h)
    end

  end
end
