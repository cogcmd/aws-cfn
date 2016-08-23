class CogCmd::Cfn::Changeset < Cog::Command
  module Show
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset show <changeset id> | <changeset name> <stack name>
    END
  end

  def show(client, request)
    cs_params = Hash[
      [
        [ :change_set_name, request.args[1] ],
        param_or_nil([ :stack_name, request.args[2] ])
      ].compact
    ]

    client.describe_change_set(cs_params).to_h
  end
end
