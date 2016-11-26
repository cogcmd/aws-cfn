require 'cog_cmd/cfn/defaults'
require 'cfn/command'
require 'cfn/branch_option'

module CogCmd::Cfn::Defaults
  class Create < Cfn::Command
    include Cfn::BranchOption

    NAME_FORMAT = /\A[\w-]*\z/
    DEFAULT_BODY = { 'params' => {}, 'tags' => {} }

    input :accumulate

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_singular_input!
      require_defaults!
      require_branch_exists!

      data = body.merge('params' => params, 'tags' => tags)
      defaults = git_client.create_defaults(name, data, branch)

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

    def require_defaults!
      if params.empty? && tags.empty?
        raise(Cog::Abort, 'Defaults must include at least a "params" or "tags" key.')
      end
    end

    def name
      request.args[0]
    end

    def params
      kv = request.options.fetch('params', [])
      hash = kv_to_hash(kv)
      body_params.merge(hash)
    end

    def tags
      kv = request.options.fetch('tags', [])
      hash = kv_to_hash(kv)
      body_tags.merge(hash)
    end

    def input
      @input ||= fetch_input
    end

    def body
      DEFAULT_BODY.merge(input[0] || {})
    end

    def body_params
      body.fetch('params')
    end

    def body_tags
      body.fetch('tags')
    end

    def kv_to_hash(kv)
      Hash[kv.map { |t| t.split('=') }]
    end
  end
end
