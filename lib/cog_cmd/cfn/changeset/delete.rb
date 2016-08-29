require_relative '../exceptions'

class CogCmd::Cfn::Changeset::Delete < Cog::SubCommand

  USAGE = <<~END
  Usage: cfn:changeset delete <change set id> | <change set name> <stack name>

  Delete a changeset. Returns a map with containing the change set name AND stack name OR the change set id, depending on which was provided to apply.

  Note: This command returns the same regardless of success or failure. Use the 'cfn:stack event' command to view the results of the delete.
  END

  def run(client)
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify either the change set id OR the change set name AND stack name."
    end

    cs_params = { change_set_name: request.args[0] }
    if stack_name = request.args[1]
      cs_params[:stack_name] = stack_name
    end

    client.delete_change_set(cs_params)

    { status: "delete initiated",
      change_set_name_or_id: request.args[0],
      stack_name: request.args[1] }
  end

end
