require_relative 'helpers'

class CogCmd::Cfn::Stack < Cog::AggregateCommand

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

  def run_command
    return if response.aborted

    if request.options['help']
      usage(subcommand.class::USAGE)
    else
      super
    end
  rescue Aws::CloudFormation::Errors::ValidationError => error
    fail(error)
  rescue Aws::CloudFormation::Errors::AccessDenied
    fail(access_denied_msg)
  rescue CogCmd::Cfn::ArgumentError => error
    usage(subcommand.class::USAGE, error)
  end

end
