#!/usr/bin/env ruby

require 'cog/command'
require_relative 'helpers'
require_relative 'exceptions'
require_relative 'changeset/create'
require_relative 'changeset/delete'
require_relative 'changeset/list'
class CogCmd::Cfn::Changeset < Cog::Command

  include CogCmd::Cfn::Helpers

  USAGE = <<-END
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

  SUBCOMMANDS = %w(create delete list)

  def run_command
    if request.options["help"]
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
      end
    rescue CogCmd::Cfn::ArgumentError => error
      usage(request.args[0], error("Missing required arguments."))
    rescue Aws::CloudFormation::Errors::ValidationError => error
      fail(error)
    end
  end

  def execute_request(method)
    # We verify that we have at least the first arg. All subcommands require
    # at least one argument. If we don't have it, we show the error message
    # along with the usage.
    unless request.args[1]
      raise CogCmd::Cfn::ArgumentError
    end

    resp = self.send(method, Aws::CloudFormation::Client.new(), request)
    response.content = resp
  end

  def usage(usage_for, err_msg = nil)
    msg = case usage_for
          when "create"
            Create::USAGE
          when "delete"
            Delete::USAGE
          when "list"
            List::USAGE
          end

    msg = msg.gsub(/^ {4}/, '')
    if err_msg
      response['body'] = "```#{msg}```\n#{error(err_msg)}"
      # Abort if there is an error message
      response.abort
    else
      # Otherwise usage was requested, so just return it
      response['body'] = "```#{msg}```"
    end
  end
end
