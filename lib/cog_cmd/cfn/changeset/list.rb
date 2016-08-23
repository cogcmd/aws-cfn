class CogCmd::Cfn::Changeset < Cog::Command
  module List
    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset list <stack name>
    END
  end

  def list(client, request)
    stack_name = request.args[1]

    changesets = client.list_change_sets({ stack_name: stack_name })

    changesets.summaries.map(&:to_h)
  end

end
