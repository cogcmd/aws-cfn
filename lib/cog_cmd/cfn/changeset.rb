require_relative 'helpers'
require_relative 'exceptions'
require_relative 'changeset/create'
require_relative 'changeset/delete'
require_relative 'changeset/list'
require_relative 'changeset/show'
require_relative 'changeset/apply'

class CogCmd::Cfn::Changeset < Cog::Command

  include CogCmd::Cfn::Helpers

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:changeset <subcommand> [options]

  Subcommands:
    create <stack name>
    delete <changeset id> | <changeset name> <stack name>
    list <stack name>
    show <changeset id> | <changeset name> <stack name>
    apply <changeset id> | <changeset name> <stack name>

  Options:
    --help, -h    Show usage
  END

  SUBCOMMANDS = %w(create delete list show apply)

  def run_command
    if request.options["help"]
      # If the user passes the '--help' flag we just call usage passing the first
      # argument. The first arg should be the subcommand.
      usage(request.args[0])
    else
      subcommand
    end
  end

  private

  def subcommand
    begin
      if SUBCOMMANDS.include?(request.args[0])
        execute_request(request.args[0].to_sym)
      elsif request.args[0] == nil
        raise CogCmd::Cfn::ArgumentError, "A subcommand must be specified."
      else
        msg = "Unknown subcommand '#{request.args[0]}'. Please specify one of '#{SUBCOMMANDS.join(', ')}'."
        raise CogCmd::Cfn::ArgumentError, msg
      end
    rescue CogCmd::Cfn::ArgumentError => error
      usage(request.args[0], error)
    rescue Aws::CloudFormation::Errors::ValidationError => error
      fail(error)
    end
  end

  def execute_request(method)
    # We verify that we have at least the first arg. All subcommands require
    # at least one argument. If we don't have it, we raise and abort returning
    # usage info.
    unless request.args[1]
      raise CogCmd::Cfn::ArgumentError, "Missing required arguments."
    end

    resp = self.send(method, Aws::CloudFormation::Client.new(), request)
    response.content = resp
  end

  # usage sets the response body to the usage info for the corresponding subcommand,
  # or the parent command if now subcommand is passed, and appends an optional error
  # message. If an error message is passed the command is aborted, otherwise it returns
  # normally.
  def usage(usage_for, err_msg = nil)

    if SUBCOMMANDS.include?(usage_for)
      msg = Object.const_get("CogCmd::Cfn::Changeset::#{usage_for.capitalize}::USAGE")
    else
      msg = USAGE
    end

    if err_msg
      # TODO: When we get templates back up and running we need to move the
      # formatting we are doing here into said template.
      response['body'] = "```#{msg}```\n#{error(err_msg)}"
      # Abort if there is an error message
      response.abort
    else
      # Otherwise usage was requested, so just return it
      # TODO: Ditto about moving formatting to the template.
      response['body'] = "```#{msg}```"
    end
  end
end
