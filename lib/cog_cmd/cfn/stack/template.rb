require 'json'
require_relative '../exceptions'

class CogCmd::Cfn::Stack::Template < Cog::Command

  USAGE = <<~END
  Usage: cfn:stack template <stack name>

  Shows the template for a stack. Returns the template body for the specified stack.
  END

  def run_command
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()
    template_body = cloudform.get_template(stack_name: request.args[0]).template_body
    JSON.parse(template_body)
  end
end
