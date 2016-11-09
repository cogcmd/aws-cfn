require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Definition
  class Show < Cfn::Command
    include Cfn::RefOptions

    NAME_FORMAT = /\A[\w-]*\z/

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_ref_exists!
      require_definition_exists!

      definition = git_client.show_definition(name, ref)[:data]

      # response.template = 'definition_show'
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

    def require_definition_exists!
      unless git_client.definition_exists?(name, ref)
        if branch = ref[:branch]
          additional = "Check that the definition exists in the #{branch} branch and has been pushed to your repository's origin."
        elsif sha = ref[:tag]
          additional = "Check that the definition exists in the #{tag} tag and has been pushed to your repository's origin."
        elsif sha = ref[:sha]
          additional = "Check that the definition exists in the git commit SHA #{sha} tag and has been pushed to your repository's origin."
        end

        raise(Cog::Abort, "Definition does not exist. #{additional}")
      end
    end

    def name
      request.args[0]
    end
  end
end
