require 'cfn/command'

module CogCmd::Cfn::Defaults
  class Ls < Cfn::Command
    include Cfn::RefOptions

    def run_command
      require_git_client!
      require_ref_exists!

      defaults = git_client.list_defaults(filter, ref)

      response.template = 'defaults_list'
      response.content = defaults
    end

    def filter
      request.args[0] || "*"
    end
  end
end
