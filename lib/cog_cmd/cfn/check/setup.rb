require 'cog_cmd/cfn/check'
require 'cfn/command'

module CogCmd::Cfn::Check
  class Setup < Cfn::Command

    # TODO: Use true and false once greenbar supports it
    def run_command
      checks = {
        git_auth: git_auth? && 1 || 0,
        git_repo_exists: git_repo_exists? && 1 || 0,
        git_repo_structure: git_repo_structure? && 1 || 0,
        aws_auth: aws_auth? && 1 || 0,
        aws_cfn_permissions: aws_cfn_permissions? && 1 || 0,
        aws_s3_permissions: aws_s3_permissions? && 1 || 0,
        aws_s3_bucket: aws_s3_bucket? && 1 || 0
      }

      response.template = 'check_setup'
      response.content = checks
    end

    def git_auth?
      git_remote_url &&
        git_ssh_key &&
        git_client &&
        true || false
    rescue Rugged::SshError => error
      error.message != "Repository not found."
    end

    def git_repo_exists?
      git_remote_url &&
        git_ssh_key &&
        git_client &&
        true || false
    rescue Rugged::SshError
      false
    end

    def git_repo_structure?
      git_repo_exists? &&
        git_client.file_exists?("defaults") &&
        git_client.file_exists?("templates") &&
        git_client.file_exists?("definitions") &&
        true || false
    end

    def aws_auth?
      s3_client &&
        cfn_client &&
        true || false
    rescue Aws::STS::Errors::AccessDenied
      false
    end

    def aws_cfn_permissions?
      aws_auth? &&
        cfn_client.list_stacks &&
        true || false
    rescue Aws::CloudFormation::Errors::AccessDenied
      false
    rescue
      false
    end

    def aws_s3_bucket?
      aws_auth? &&
        s3_stack_definition_bucket &&
        s3_client.bucket_exists? &&
        true || false
    rescue Aws::S3::Errors::NotFound
      false
    rescue Aws::S3::Errors::Forbidden
      true
    end

    def aws_s3_permissions?
      aws_auth? &&
        aws_s3_bucket? &&
        true || false
    rescue Aws::S3::Errors::Forbidden
      false
    end
  end
end
