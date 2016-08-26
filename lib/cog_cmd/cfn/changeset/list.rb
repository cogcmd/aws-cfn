require_relative '../exceptions'

class CogCmd::Cfn::Changeset::List < Cog::SubCommand

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:changeset list <stack name>

  List changesets for a stack. Returns a list of changeset summaries equivalent to resp.summaries documented here, http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudFormation/Client.html#list_change_sets-instance_method
  END

  def run(client)
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify the stack name."
    end

    stack_name = request.args[0]

    changesets = client.list_change_sets({ stack_name: stack_name })

    changesets.summaries.map(&:to_h)
  end

end
