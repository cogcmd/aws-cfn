class CogCmd::Cfn::Changeset < Cog::Command
  module Delete
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset delete <changeset id> | <changeset name> <stack name>
    END
  end

  def delete(client, request)
    cs_params = Hash[
      [
        [ :change_set_name, request.args[1] ],
        param_or_nil([ :stack_name, request.args[2] ])
      ].compact
    ]

    client.delete_change_set(cs_params)

    { status: "deleted",
      changeset_name_or_id: request.args[1],
      stack_name: request.args[2] }
  end

end
