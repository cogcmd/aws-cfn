require_relative 'helpers'

class CogCmd::Cfn::Stack < Cog::Command

  include CogCmd::Cfn::Helpers

  SUBCOMMANDS = %w(create list show delete events resources template)

  USAGE = <<~END
  Usage: cfn:stack <subcommand> [options]

  Manages stacks.

  Subcommands:
    create <stack name> <template name>
    list
    show <stack name>
    delete <stack name>
    events <stack name>
    resources <stack name>
    template <stack name>

  Options:
    --help, -h     Show usage
  END

  def run_command
  end

end
