require 'cog_cmd/cfn/changeset'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class List < Cog::Command

    attr_reader :stack_name

    def initialize
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Error, "Error: You must specify the stack name.") if stack_name.nil?

      changesets = list_change_sets

      if changesets.empty?
        raise(Cog::Abort, "#{name}: No changesets found for #{stack_name}. You can use cfn:changeset-create to create some.")
      end


      response.template = 'changeset_list'
      response.content = list_change_sets
    rescue Aws::CloudFormation::Errors::ValidationError
      response.template = nil
      response.content = "Error: Unable to list templates for stack #{stack_name}."
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
