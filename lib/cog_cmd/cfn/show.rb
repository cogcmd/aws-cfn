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

end
