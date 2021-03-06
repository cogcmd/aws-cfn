require 'cog_cmd/cfn/defaults'
require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Defaults
  class Show < Cfn::Command
    include Cfn::RefOptions

    NAME_FORMAT = /\A[\w-]*\z/

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_ref_exists!
      require_defaults_exists!

      defaults = git_client.show_defaults(name, ref)[:data]

      defaults['meta'] ||= {}
      defaults['meta']['name'] = name
      defaults['param_list'] = map_to_list(defaults['params']) if defaults['params']
      defaults['tag_list'] = map_to_list(defaults['tags']) if defaults['tags']

      response.template = 'defaults_show'
      response.content = defaults
    end

    def map_to_list(data)
      data.map { |k,v| "#{k}=#{v}" }
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

    def require_defaults_exists!
      unless git_client.defaults_exists?(name, ref)
        if branch = ref[:branch]
          additional = "Check that the defaults file exists in the #{branch} branch and has been pushed to your repository's origin."
        elsif sha = ref[:tag]
          additional = "Check that the defaults file exists in the #{tag} tag and has been pushed to your repository's origin."
        elsif sha = ref[:sha]
          additional = "Check that the defaults file exists in the git commit SHA #{sha} tag and has been pushed to your repository's origin."
        end

        raise(Cog::Abort, "Defaults file does not exist. #{additional}")
      end
    end

    def name
      request.args[0]
    end
  end
end
