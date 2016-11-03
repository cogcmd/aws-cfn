require 'cog/command'
require 'cfn/git_client'

module Cfn
  class Command < Cog::Command
    def git_client
      @_git_client ||= Cfn::GitClient.new(git_remote_url, git_ssh_key)
    end

    def require_git_client!
      require_git_remote_url!
      require_git_ssh_key!

      git_client # Clones the repository, then creates and memoizes the client
    end

    def require_git_remote_url!
      unless git_remote_url
        raise(Cog::Error, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
      end
    end

    def require_git_ssh_key!
      unless git_ssh_key
        raise(Cog::Error, '`GIT_SSH_KEY` not set. Set the `GIT_SSH_KEY` environment variable an ssh key that has access to your git repository.')
      end
    end

    def git_remote_url
      ENV['GIT_REMOTE_URL']
    end

    def git_ssh_key
      ENV['GIT_SSH_KEY']
    end
  end
end
