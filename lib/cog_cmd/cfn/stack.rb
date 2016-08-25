require_relative 'aggregate_command'
require_relative 'subcommand'
require_relative 'stack/create'

class CogCmd::Cfn::Stack < Cog::AggregateCommand

  DOCUMENTATION_URL = "https://github.com/cogcmd/aws-cfn"

  SUBCOMMANDS = %w(create)

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack <subcommand> [options]

  Subcommands:
    create <stack name>
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
