require 'cfn/command'

module CogCmd::Cfn::Template
  class Ls < Cfn::Command
    def run_command
      require_git_client!
      require_ref_exists!

      templates = git_client.list_templates(filter, ref)

      response.template = 'template_list'
      response.content = templates
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

    def filter
      request.args[0] || "*"
    end
  end
end
