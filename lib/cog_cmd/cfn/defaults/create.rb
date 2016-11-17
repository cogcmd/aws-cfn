require 'cog_cmd/cfn/defaults'
require 'cfn/command'
require 'cfn/branch_option'

module CogCmd::Cfn::Defaults
  class Create < Cfn::Command
    include Cfn::BranchOption

    NAME_FORMAT = /\A[\w-]*\z/

    input :accumulate

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_singular_input!
      require_input_structure!
      require_branch_exists!

      defaults = git_client.create_defaults(name, params || {}, tags || {}, branch)

      response.template = 'defaults_create'
      response.content = defaults
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

    def require_singular_input!
      if input.size > 1
        raise(Cog::Abort, 'Input from previous command must only include a single item.')
      end
    end

    def require_input_structure!
      if !params && !tags
        raise(Cog::Abort, 'Input must include at least a "params" or "tags" key.')
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

    def params
      body['params']
    end

    def tags
      body['tags']
    end
  end
end
