require 'cfn/command'

module CogCmd::Cfn::Defaults
  class Create < Cfn::Command
    NAME_FORMAT = /\A[\w-]*\z/

    input :accumulate

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_singular_input!
      require_branch_exists!

      defaults = git_client.create_defaults(name, body, branch)

      response.template = 'defaults_create'
      response.content = defaults
    end

    def require_name!
      unless name
        raise(Cog::Error, 'Name not provided. Provide a name as the first argument.')
      end
    end

    def require_name_format!
      unless NAME_FORMAT.match(name)
        raise(Cog::Error, 'Name must only include word characters [a-zA-Z0-9_-].')
      end
    end

    def require_singular_input!
      if input.size > 1
        raise(Cog::Error, 'Input from previous command must only include a single item.')
      end
    end

    def require_branch_exists!
      unless git_client.branch_exists?(branch)
        raise(Cog::Error, "Branch #{branch} does not exist. Create a branch and push it to your repository's origin and try again.")
      end
    end

    def name
      request.args[0]
    end

    def input
      @input ||= fetch_input
    end

    def body
      input[0]
    end

    def branch
      request.options['branch'] || 'master'
    end
  end
end
