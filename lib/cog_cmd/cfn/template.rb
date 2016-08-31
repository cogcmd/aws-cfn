require_relative 'aggregate_command'

class CogCmd::Cfn::Template < CogCmd::Cfn::AggregateCommand

  SUBCOMMANDS = %w(list show)

  USAGE = <<~END
  Usage: cfn:template <subcommand> [options]

  Get information on CloudFormation templates.

  Subcommands:
    list
    show <template name> | -s <stack name>

  Options:
    --help, -h     Show Usage
  END

  def run_command
    super
  rescue Aws::S3::Errors::NoSuchBucket => error
    docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
    msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
    fail(msg)
  end

end
