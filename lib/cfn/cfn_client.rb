require 'aws-sdk'
require 'naturalsorter'
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

    def describe_stack(stack_name)
      result = @client.describe_stacks(stack_name: stack_name).stacks[0].to_h

      sort_order = {
        :parameters => :parameter_key,
        :tags => :key,
        :outputs => :output_key
      }

      sort_order.keys.each do |type|
        next unless result[type]
        result[type] = result[type].sort_by { |map| map[sort_order[type]] }
      end

      result
    end

    def describe_change_set(change_set_name:, stack_name: nil)
      options = { change_set_name: change_set_name }
      options[:stack_name] = stack_name unless stack_name.nil?

      resp = @client.describe_change_set(options)
      sorted_params = Naturalsorter::Sorter.sort_by_method(resp.parameters, "parameter_key", true)
      resp.to_h.merge(parameters: sorted_params.map(&:to_h))
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
