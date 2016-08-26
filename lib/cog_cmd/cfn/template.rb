require_relative 'aggregate_command'
require_relative 'subcommand'
require_relative 'helpers'

class CogCmd::Cfn::Template < Cog::AggregateCommand

  SUBCOMMANDS = %w(list show)

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:template <subcommand>

  Subcommands:
    list
    show <template name> | -s <stack name>
  END

  def run_subcommand
    begin
      resp = subcommand.run
      response.content = resp
    rescue Aws::S3::Errors::NoSuchBucket => error
      docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
      msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
      fail(msg)
    rescue Aws::CloudFormation::Errors::AccessDenied
      fail(access_denied_msg)
    end
  end
end

require_relative 'template/list'
require_relative 'template/show'
