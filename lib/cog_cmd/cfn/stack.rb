require_relative 'helpers'
require_relative 'exceptions'

class CogCmd::Cfn::Stack < Cog::Command

  include CogCmd::Cfn::Helpers

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack <subcommand> [options]
  END

  SUBCOMMANDS = %w()

  def run_command
    if request.options['help']
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
    resp = self.send(method, Aws::CloudFormation::Client.new(), request)
    response.content = resp
  end

  # usage sets the response body to the usage info for the corresponding subcommand,
  # or the parent command if now subcommand is passed, and appends an optional error
  # message. If an error message is passed the command is aborted, otherwise it returns
  # normally.
  def usage(usage_for, err_msg = nil)

    if SUBCOMMANDS.include?(usage_for)
      msg = Object.const_get("CogCmd::Cfn::Stack::#{usage_for.capitalize}::USAGE")
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
