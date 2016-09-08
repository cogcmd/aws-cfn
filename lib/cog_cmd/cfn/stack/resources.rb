require_relative '../exceptions'

class CogCmd::Cfn::Stack::Resources < Cog::Command

  USAGE = <<~END
  Usage: cfn:stack resources <stack name>

  Lists stack resources.
  END

  def run_command
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()

    resp = cloudform.list_stack_resources(stack_name: request.args[0])
    resp.stack_resource_summaries.map(&:to_h)
  end
end
