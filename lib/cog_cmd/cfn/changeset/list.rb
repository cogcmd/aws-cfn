class CogCmd::Cfn::Changeset < Cog::Command
  module List
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset list <stack name>

    List changesets for a stack. Returns a list of changeset summaries equivalent to resp.summaries documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#list_change_sets-instance_method
    END
  end

  def list(client, request)
    stack_name = request.args[1]

    changesets = client.list_change_sets({ stack_name: stack_name })

    changesets.summaries.map(&:to_h)
  end

end
