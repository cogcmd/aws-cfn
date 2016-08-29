require_relative 'helpers'
require_relative 'aggregate_command'
require_relative 'exceptions'

class CogCmd::Cfn::Changeset < Cog::AggregateCommand

  include CogCmd::Cfn::Helpers

  SUBCOMMANDS = %w(create delete list show apply)

  USAGE = <<~END
  Usage: cfn:changeset <subcommand> [options]

  Subcommands:
    create <stack name>
    delete <change set id> | <change set name> <stack name>
    list <stack name>
    show <change set id> | <change set name> <stack name>
    apply <change set id> | <change set name> <stack name>

  Options:
    --help, -h    Show usage
  END

  def run_subcommand
    begin
      client = Aws::CloudFormation::Client.new()
      resp = subcommand.run(client)
      response.content = resp
    rescue Aws::CloudFormation::Errors::ValidationError => error
      fail(error)
    rescue Aws::CloudFormation::Errors::AccessDenied
      fail(access_denied_msg)
    end
  end
end

require_relative 'changeset/create'
require_relative 'changeset/delete'
require_relative 'changeset/list'
require_relative 'changeset/show'
require_relative 'changeset/apply'
