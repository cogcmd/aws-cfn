require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class Show < Cog::Command

    attr_reader :changeset_name_or_id, :stack_name

    def initialize
      @changeset_name_or_id = request.args[0]
      @stack_name = request.args[1]
    end

    def run_command
      raise(Cog::Error, "You must specify either the change set id OR the change set name AND stack name.") unless changeset_name_or_id

      response.template = 'changeset_show'
      response.content = show_changeset
    end

    private

    def show_changeset
      client = Aws::CloudFormation::Client.new()

      cs_params = {
        change_set_name: changeset_name_or_id,
        stack_name: stack_name
      }.reject { |_key, value| value.nil? }

      client.describe_change_set(cs_params).to_h
    end

  end
end
