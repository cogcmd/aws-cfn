require_relative '../exceptions'

class CogCmd::Cfn::Changeset::Show < Cog::SubCommand

  USAGE = <<~END
  Usage: cfn:changeset show <change set id> | <change set name> <stack name>

  Shows changeset details. Returns a map equivalent to the response object documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#describe_change_set-instance_method
  END

  def run_command
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify either the change set id OR the change set name AND stack name."
    end

    client = Aws::CloudFormation::Client.new()

    cs_params = { change_set_name: request.args[0] }
    if stack_name = request.args[1]
      cs_params[:stack_name] = stack_name
    end

    client.describe_change_set(cs_params).to_h
  end
end
