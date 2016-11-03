require 'cfn/command'

module CogCmd::Cfn::Defaults
  class Show < Cfn::Command
    NAME_FORMAT = /\A[\w-]*\z/

    def run_command
      require_git_client!
      require_name!
      require_name_format!
      require_ref_exists!
      require_defaults_exists!

      file = git_client.show_defaults(name, ref)

      response.template = 'defaults_show'
      response.content = [file]
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

    def require_ref_exists!
      unless git_client.ref_exists?(ref)
        if branch = ref[:branch]
          raise(Cog::Error, "Branch #{branch} does not exist. Create a branch, push it to your repository's origin, and try again.")
        elsif sha = ref[:tag]
          raise(Cog::Error, "Tag #{tag} does not exist. Create a tag, push it to your repository's origin, and try again.")
        elsif sha = ref[:sha]
          raise(Cog::Error, "Git commit SHA #{sha} does not exist. Check that the SHA you are referencing has been pushed to your repository's origin and try again.")
        end
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

        raise(Cog::Error, "Defaults file does not exist. #{additional}")
      end
    end

    def name
      request.args[0]
    end

    def ref
      if branch
        { branch: branch }
      elsif tag
        { tag: tag }
      elsif sha
        { sha: sha }
      else
        { branch: 'master' }
      end
    end

    def branch
      request.options['branch']
    end

    def tag
      request.options['tag']
    end

    def sha
      request.options['sha']
    end
  end
end
