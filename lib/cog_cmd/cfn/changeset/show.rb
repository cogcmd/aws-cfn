class CogCmd::Cfn::Changeset < Cog::Command
  module Show
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset show <change set id> | <change set name> <stack name>

    Show changeset details. Returns a map equivalent to the response object documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#describe_change_set-instance_method
    END
  end

  def show(client, request)
    cs_params = { change_set_name: request.args[1] }
    if stack_name = request.args[2]
      cs_params[:stack_name] = stack_name
    end

    client.describe_change_set(cs_params).to_h
  end
end
