require_relative '../exceptions'

class CogCmd::Cfn::Stack::Events < Cog::Command

  USAGE = <<~END
  Usage: cfn:stack events <stack name>

  Lists events for a stack. Returns all stack related events for a specified stack in reverse chronological order.

  Options:
    --limit <int>
  END

  def run_command
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()
    stack_events = cloudform.describe_stack_events(stack_name: request.args[0]).stack_events

    if limit = request.options['limit']
      stack_events.slice(0, limit.to_i).map(&:to_h)
    else
      stack_events.map(&:to_h)
    end
  end
end
