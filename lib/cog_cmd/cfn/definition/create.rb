require 'cog_cmd/cfn/definition'
require 'cfn/command'
require 'cfn/branch_option'
require 'cfn/definition'

module CogCmd::Cfn::Definition
  class Create < Cfn::Command
    include Cfn::BranchOption

    NAME_FORMAT = /\A[\w-]*\z/

    input :accumulate

    def run_command
      require_git_client!
      require_s3_client!
      require_name!
      require_name_format!
      require_branch_exists!
      require_template!
      require_template_format!
      require_template_exists!
      require_defaults_exist!

      definition = Cfn::Definition.create(git_client, s3_client, {
        name: name,
        template: template,
        defaults: defaults,
        params: params,
        tags: tags,
        branch: branch
      })

      response.template = 'definition_create'
      response.content = [definition]
    end

    def require_name!
      unless name
        raise(Cog::Abort, 'Name not provided. Provide a name as the first argument.')
      end
    end

    def require_name_format!
      unless NAME_FORMAT.match(name)
        raise(Cog::Abort, 'Name must only include word characters [a-zA-Z0-9_-].')
      end
    end

    def require_template!
      unless template
        raise(Cog::Abort, 'Template not provided. Provide a template as the second argument.')
      end
    end

    def require_template_format!
      unless NAME_FORMAT.match(template)
        raise(Cog::Abort, 'Template must only include word characters [a-zA-Z0-9_-].')
      end
    end

    def require_template_exists!
      unless git_client.template_exists?(template, { branch: branch })
        raise(Cog::Abort, "Template does not exist. Check that the template exists in the #{branch} branch and has been pushed to your repository's origin.")
      end
    end

    def require_defaults_exist!
      defaults.each do |defaults_name|
        unless git_client.defaults_exists?(defaults_name, { branch: branch })
          raise(Cog::Abort, "Defaults file #{defaults_name} does not exist. Check that the defaults file exists in the #{branch} branch and has been pushed to your repository's origin.")
        end
      end
    end

    def name
      request.args[0]
    end

    def template
      request.args[1]
    end

    def defaults
      request.options['defaults']
    end

    def params
      request.options['params']
    end

    def tags
      request.options['tags']
    end
  end
end
