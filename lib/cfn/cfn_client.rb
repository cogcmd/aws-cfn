require 'aws-sdk'
require 'time'

module Cfn
  class CfnClient
    def initialize(aws_sts_role_arn = nil)
      update_aws_credentials(aws_sts_role_arn) if aws_sts_role_arn

      @client = Aws::CloudFormation::Client.new
    end

    def list_stacks
      @client.list_stacks
    end

    def validate_template(template_body)
      @client.validate_template(template_body: template_body)
    end

    def update_aws_credentials(aws_sts_role_arn)
      Aws.config.update(
        credentials: Aws::AssumeRoleCredentials.new(
          role_arn: aws_sts_role_arn,
          role_session_name: "cog-#{ENV['COG_USER']}"
        )
      )
    end
  end
end
