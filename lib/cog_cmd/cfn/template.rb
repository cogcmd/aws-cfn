require_relative 'helpers'

class CogCmd::Cfn::Template < Cog::AggregateCommand

  include CogCmd::Cfn::Helpers

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
    return if response.aborted

    if request.options['help']
      usage(subcommand.class::USAGE)
    else
      super
    end
  rescue Aws::S3::Errors::NoSuchBucket => error
    docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
    msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
    fail(msg)
  rescue Aws::CloudFormation::Errors::AccessDenied
    fail(access_denied_msg)
  rescue CogCmd::Cfn::ArgumentError => error
    usage(subcommand.class::USAGE, error)
  end
end
