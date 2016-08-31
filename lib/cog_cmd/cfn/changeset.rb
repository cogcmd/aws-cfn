require_relative 'helpers'

class CogCmd::Cfn::Changeset < CogCmd::Cfn::AggregateCommand

  include CogCmd::Cfn::Helpers

  SUBCOMMANDS = %w(create delete list show apply)

  USAGE = <<~END
  Usage: cfn:changeset <subcommand> [options]

  Manages changesets.

  Subcommands:
    create <stack name>
    delete <change set id> | <change set name> <stack name>
    list <stack name>
    show <change set id> | <change set name> <stack name>
    apply <change set id> | <change set name> <stack name>

  Options:
    --help, -h    Show usage
  END

end

