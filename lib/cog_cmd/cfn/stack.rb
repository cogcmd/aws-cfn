require_relative 'aggregate_command'
require_relative 'subcommand'
require_relative 'helpers'

class CogCmd::Cfn::Stack < Cog::AggregateCommand

  include CogCmd::Cfn::Helpers

  SUBCOMMANDS = %w(create list show delete event resource template)

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack <subcommand> [options]

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
require_relative 'stack/resource'
require_relative 'stack/template'
