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
    cf_params = [
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

    begin
      response.content = {
        stack_id: cloudform.create_stack(Hash[ cf_params ]).stack_id
      }
    rescue Aws::CloudFormation::Errors::AccessDenied
      msg = <<-END.gsub(/^ {5}|\n/, '')
      Access Denied. Make sure that you have the proper permissions with AWS
      to create a CloudFormation stack, and that your credentials have been
      configured properly with Cog. #{DOCUMENTATION_URL}#configuration
      END
      fail(msg)
    end
  end

  def param_or_nil(param)
    return if param[1] == nil
    param
  end

  def get_parameters(params)
    return unless params
    params.map do |p|
      param = p.strip.split("=")
      { parameter_key: param[0],
        parameter_value: param[1] }
    end
  end

  def get_tags(tags)
    return unless tags
    tags.map do |t|
      tag = t.strip.split("=")
      { key: tag[0],
        value: tag[1] }
    end
  end

  def get_on_failure(on_failure)
    return unless on_failure

    case on_failure.upcase
    when "KEEP"
      "DO_NOTHING"
    when "DO_NOTHING"
      "DO_NOTHING"
    when "ROLLBACK"
      "ROLLBACK"
    when "DELETE"
      "DELETE"
    else
      fail("Unknown action '#{on_failure}' for --on-failure. Must be one of ['KEEP', 'ROLLBACK', 'DELETE']")
    end
  end

  def get_capabilities(capabilities)
    return unless capabilities

    capabilities.map { |c| capability(c) }.compact
  end

  def capability(cp)
    return unless cp

    case cp.upcase
    when "IAM"
      "CAPABILITY_IAM"
    when "NAMED_IAM"
      "CAPABILITY_NAMED_IAM"
    else
      fail("Unknown capability '#{cp}'. Must be one of ['IAM', 'NAMED_IAM']")
    end
  end

end
