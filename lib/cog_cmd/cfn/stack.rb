require_relative 'helpers'

class CogCmd::Cfn::Stack < CogCmd::Cfn::AggregateCommand

  include CogCmd::Cfn::Helpers

  SUBCOMMANDS = %w(create list show delete event resource template)

  USAGE = <<~END
  Usage: cfn:stack <subcommand> [options]

  Manages stacks.

  Subcommands:
    create <stack name> <template name>
    list
    show <stack name>
    delete <stack name>
    event <stack name>
    resource <stack name>
    template <stack name>

  Options:
    --help, -h     Show usage
  END

end
