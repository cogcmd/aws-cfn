require_relative 'helpers'

class CogCmd::Cfn::AggregateCommand < Cog::AggregateCommand

  include CogCmd::Cfn::Helpers

  def run_command
    if request.options['help']
      response['body'] = usage(subcommand.class::USAGE)
    else
      super
    end
  rescue Aws::CloudFormation::Errors::ValidationError => error
    fail(error)
  rescue Aws::CloudFormation::Errors::AccessDenied
    fail(access_denied_msg)
  rescue CogCmd::Cfn::ArgumentError => error
    response['body'] = usage(subcommand.class::USAGE, error)
  end

  def require_subcommand!(subcommand, subcommands)
    if request.options['help']
      super(subcommand, subcommands, Cog::Stop)
    else
      super(subcommand, subcommands)
    end
  end

  def missing_subcommand_msg(subcommands)
    if request.options['help']
      usage(self.class::USAGE)
    else
      usage(self.class::USAGE, error(super(subcommands)))
    end
  end

  def unknown_subcommand_msg(subcommand, subcommands)
    usage(self.class::USAGE, error(super(subcommand, subcommands)))
  end
end
