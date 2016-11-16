require 'cog/command'
require 'cfn/git_client'
require 'cfn/s3_client'

module Cfn
  class Command < Cog::Command
    def git_client
      @_git_client ||= Cfn::GitClient.new(git_remote_url, git_ssh_key)
    end

    def s3_client
      @_s3_client ||= Cfn::S3Client.new(s3_stack_definition_bucket, s3_stack_definition_prefix, aws_sts_role_arn)
    end

    def require_git_client!
      require_git_remote_url!
      require_git_ssh_key!

      git_client # Clones the repository, then creates and memoizes the client
    end

    def require_s3_client!
      require_s3_stack_definition_bucket!

      s3_client
    end

    def require_git_remote_url!
      unless git_remote_url
        raise(Cog::Abort, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
      end
    end

    def require_git_ssh_key!
      unless git_ssh_key
        raise(Cog::Abort, '`GIT_SSH_KEY` not set. Set the `GIT_SSH_KEY` environment variable to an ssh key that has access to your git repository.')
      end
    end

    def require_s3_stack_definition_bucket!
      unless s3_stack_definition_bucket
        raise(Cog::Abort, '`S3_STACK_DEFINITION_BUCKET` not set. Set the `S3_STACK_DEFINITION_BUCKET` environment variable to the name of the bucket used to read and write stack definitions.')
      end
    end

    def git_remote_url
      ENV['GIT_REMOTE_URL']
    end

    def git_ssh_key
      ENV['GIT_SSH_KEY']
    end

    def aws_sts_role_arn
      ENV['AWS_STS_ROLE_ARN']
    end

    def s3_stack_definition_bucket
      ENV['S3_STACK_DEFINITION_BUCKET']
    end

    def s3_stack_definition_prefix
      ENV['S3_STACK_DEFINITION_PREFIX']
    end
  end
end
