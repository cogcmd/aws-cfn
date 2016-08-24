class CogCmd::Cfn::Changeset < Cog::Command
  module Delete
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset delete <change set id> | <change set name> <stack name>
    END
  end

  def delete(client, request)
    cs_params = { change_set_name: request.args[1] }
    if stack_name = request.args[2]
      cs_params[:stack_name] = stack_name
    end

    client.delete_change_set(cs_params)

    { status: "deleted",
      change_set_name_or_id: request.args[1],
      stack_name: request.args[2] }
  end

end
