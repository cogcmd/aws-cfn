#!/usr/bin/env ruby

require_relative 'helpers'

class CogCmd::Cfn::Create < Cog::Command

  DOCUMENTATION_URL = "https://github.com/cogcmd/aws-cfn"

  include CogCmd::Cfn::Helpers

  def run_command
    if request.args.length < 2
      usage("ERROR: A stack name and template name are required to continue.")
      return
    end

    create()
  end

  private

  def usage(error_msg = "")
    usage_msg = <<END
Usage: cfn:create <name> <s3_template_name>
  Options:
      --param, -p "Key1=Value1"
      --param, -p "Key2=Value2"
      --tag, -t "Name1=Value1"
      --tag, -t "Name2=Value2"
      --policy, -o <s3_policy_name>
      --notify, -n "sns_topic_arn1"
      --notify, -n "sns_topic_arn2"
      --on-failure, -f <rollback *|delete|keep>
      --timeout, -e <minutes>
      --capabilities, -c <iam|named_iam>
END

    unless error_msg == ""
      error_msg.concat("\n\n")
    end

    response["body"] = "#{error_msg} #{usage_msg}"
  end

  def create
    cloudform = Aws::CloudFormation::Client.new()
    cf_params = Hash[
      [
        [ :stack_name, request.args[0] ],
        [ :template_url, template_url(request.args[1]) ],
        param_or_nil([ :parameters, get_parameters(request.options["param"]) ]),
        param_or_nil([ :tags, get_tags(request.options["tag"]) ]),
        param_or_nil([ :stack_policy_url, policy_url(request.options["policy"]) ]),
        param_or_nil([ :notification_arns, request.options["notify"] ]),
        param_or_nil([ :on_failure, get_on_failure(request.options["on-failure"]) ]),
        param_or_nil([ :timeout_in_minutes, request.options["timeout"] ]),
        param_or_nil([ :capabilities, get_capabilities(request.options["capabilities"]) ])
      ].compact
    ]

    begin
      cloudform.create_stack(cf_params)
      stack = cloudform.describe_stacks(stack_name: request.args[0]).stacks[0]
      response.content = stack.to_h
    rescue Aws::CloudFormation::Errors::AccessDenied
      msg = <<-END.gsub(/^ {5}|\n/, '')
      Access Denied. Make sure that you have the proper permissions with AWS
      to create a CloudFormation stack, and that your credentials have been
      configured properly with Cog. #{DOCUMENTATION_URL}#configuration
      END
      fail(msg)
    end
  end

end
