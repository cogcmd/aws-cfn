class CogCmd::Cfn::Changeset < Cog::Command
  module Apply
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset apply <change set id> | <change set name> <stack name>

    Apply a changeset to a stack. Returns a map with status set to "applied" along with the change set name AND stack name OR the change set id, depending on which was provided to apply.

    Note: This command returns the same regardless of success or failure. Use the cfn:event command to view the results of the apply.
    END
  end

  def apply(client, request)
    cs_params = { change_set_name: request.args[1] }
    if stack_name = request.args[2]
      cs_params[:stack_name] = stack_name
    end

    client.execute_change_set(cs_params)
    { status: "applied" ,
      change_set_name_or_id: request.args[1],
      stack_name: request.args[2] }
  end
end
