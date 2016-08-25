require_relative 'aggregate_command'
require_relative 'subcommand'

class CogCmd::Cfn::Stack < Cog::AggregateCommand

  DOCUMENTATION_URL = "https://github.com/cogcmd/aws-cfn"

  SUBCOMMANDS = %w(create list show delete)

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack <subcommand> [options]

  Subcommands:
    create <stack name>
    list
    show <stack name>
    delete <stack name>
  END

  def run_subcommand
    begin
      resp = subcommand.run
      response.content = resp
    rescue CogCmd::Cfn::ArgumentError => error
      usage(error)
    rescue Aws::CloudFormation::Errors::ValidationError => error
      fail(error)
    rescue Aws::CloudFormation::Errors::AccessDenied
      msg = <<-END.gsub(/^ {5}|\n/, '')
      Access Denied. Make sure that you have the proper permissions with AWS
      to create a CloudFormation stack, and that your credentials have been
      configured properly with Cog. #{DOCUMENTATION_URL}#configuration
      END
      fail(msg)
    end
  end

end

require_relative 'stack/create'
require_relative 'stack/list'
require_relative 'stack/show'
require_relative 'stack/delete'
