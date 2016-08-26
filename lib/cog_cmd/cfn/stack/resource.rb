require_relative '../exceptions'

class CogCmd::Cfn::Stack::Resource < Cog::SubCommand

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack resource <stack name>

  Returns the list of stack resources.
  END

  def run
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()

    resp = cloudform.list_stack_resources(stack_name: request.args[0])
    resp.stack_resource_summaries.map(&:to_h)
  end
end
