require 'cog_cmd/cfn/template'
require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Template
  class List < Cfn::Command
    include Cfn::RefOptions

    def run_command
      require_git_client!
      require_ref_exists!

      templates = git_client.list_templates(filter, ref)

      if templates.empty?
        raise(Cog::Abort, "#{name}: No templates found in repository.")
      end

      response.template = 'template_list'
      response.content = templates
    end

    def filter
      request.args[0] || '**/*'
    end
  end
end
