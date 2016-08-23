class CogCmd::Cfn::Changeset < Cog::Command
  module Apply
    USAGE = <<-END
    Usage: cfn:changeset apply <changeset id> | <changeset name> <stack name>
    END
  end

  def apply(client, request)
    cs_params = Hash[
      [
        [ :change_set_name, request.args[1] ],
        param_or_nil([ :stack_name, request.args[2] ])
      ].compact
    ]

    client.execute_change_set(cs_params)
    { status: "applied" ,
      changeset_name_or_id: request.args[1] }
  end
end
