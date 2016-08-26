require_relative 'aggregate_command'
require_relative 'subcommand'

class CogCmd::Cfn::Stack < Cog::AggregateCommand

  SUBCOMMANDS = %w(create list show delete event)

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack <subcommand> [options]

  Subcommands:
    create <stack name> <template name>
    list
    show <stack name>
    delete <stack name>
    event <stack name>

  Options:
    --help, -h     Show usage
  END

  def run_subcommand
    begin
      resp = subcommand.run
      response.content = resp
    rescue Aws::CloudFormation::Errors::ValidationError => error
      fail(error)
    rescue Aws::CloudFormation::Errors::AccessDenied
      fail(access_denied_msg)
    end
  end

end

require_relative 'stack/create'
require_relative 'stack/list'
require_relative 'stack/show'
require_relative 'stack/delete'
require_relative 'stack/event'
