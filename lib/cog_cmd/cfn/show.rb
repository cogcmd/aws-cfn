#!/usr/bin/env ruby

require_relative 'helpers'

class CogCmd::Cfn::Show < Cog::Command

  DOCUMENTATION_URL = "https://github.com/cogcmd/aws-cfn"

  include CogCmd::Cfn::Helpers

  def run_command
    if request.args.length != 1
      usage("ERROR: A stack name and template name are required to continue.")
      return
    end

    describe_resources()
  end

  private

  def usage(error_msg = "")
    usage_msg = "Usage: cfn:show <name>"

    unless error_msg == ""
      error_msg.concat("\n\n")
    end

    response["body"] = "#{error_msg} #{usage_msg}"
  end

  def describe_resources
    cloudform = Aws::CloudFormation::Client.new()
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
