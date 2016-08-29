require_relative '../exceptions'
require_relative '../helpers'

class CogCmd::Cfn::Stack::Show < Cog::SubCommand

  include CogCmd::Cfn::Helpers

  USAGE = <<~END
  Usage: cfn:stack show <stack name>

  Returns the specified stack.
  END

  def run
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()
    cloudform.describe_stacks(stack_name: request.args[0]).stacks[0].to_h
  end

end
