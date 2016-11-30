require 'cog_cmd/cfn/definition'
require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Definition
  class List < Cfn::Command
    include Cfn::RefOptions

    def run_command
      require_git_client!
      require_ref_exists!

      definitions = git_client.list_definitions(filter, ref)

      if definitions.empty?
        raise(Cog::Abort, "#{name}: No definitions found. You can use cfn:definition-create to create one.")
      end

      response.template = 'definition_list'
      response.content = definitions
    end

    def filter
      request.args[0] || '*'
    end
  end
end
