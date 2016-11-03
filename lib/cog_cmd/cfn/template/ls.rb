require 'cfn/command'

module CogCmd::Cfn::Template
  class Ls < Cfn::Command
    include Cfn::RefOptions

    def run_command
      require_git_client!
      require_ref_exists!

      templates = git_client.list_templates(filter, ref)

      response.template = 'template_list'
      response.content = templates
    end

    def filter
      request.args[0] || "*"
    end
  end
end
