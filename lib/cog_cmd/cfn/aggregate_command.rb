require_relative 'helpers'
require_relative 'exceptions'

# Cog::AggregateCommand is a superclass for commands with subcommands.
# Child classes need a two things, a method called 'run_subcommand' where the
# user can run the subcommand and collect the response or deal with any errors,
# and a constant USAGE where the usage string for the aggregate command is stored.
#
# Subcommands are defined as children of the Cog::SubCommand class.
class Cog
  class AggregateCommand < Cog::Command

    # We only use the 'error' method from helpers right now. It just prepends
    # 'cfn: Error: ' to the error message. We will need to generalize or remove
    # that bit if we move aggregate command up to cog-rb.
    include CogCmd::Cfn::Helpers

    def initialize
      @subcommand_string = request.args.shift
      @subcommands = self.class.const_get("SUBCOMMANDS")
    end

    # Since Cog::AggregateCommand inherits from Cog::Command we define run_command
    # run_command is invoked when the command in executed.
    def run_command
      begin
        # If the subcommand is valid then we call either call 'run_subcommand'
        # or, if the user requested it, get the usage info for the subcommand.
        # 'run_subcommand' should be defined in the child class.
        if create_subcommand_class
          request.options['help'] ? usage : run_subcommand
        # If there are no arguments we throw an argument error
        elsif @subcommand_string == nil
          raise CogCmd::Cfn::ArgumentError, "A subcommand must be specified."
        # If the subcommand is unknown, we throw an argument error
        else
          msg = "Unknown subcommand '#{@subcommand_string}'. Please specify one of '#{@subcommands.join(', ')}'."
          raise CogCmd::Cfn::ArgumentError, msg
        end
      # Argument errors are rescued here so we can show the usage a message along with
      # the error.
      rescue CogCmd::Cfn::ArgumentError => error
        usage(error)
      end
    end

    private

    def subcommand
      @subcommand_inst ||= @subcommand_class.new(request)
    end

    def create_subcommand_class
      @subcommand_class = nil

      if @subcommands.include?(@subcommand_string)
        subcommand_class = @subcommand_string.gsub(/(\A|_)([a-z])/) { $2.upcase }
        @subcommand_class = self.class.const_get(subcommand_class)
      end

      @subcommand_class
    end

    # usage accepts an optional error message. If an error message is passed
    # then we abort. If an error is not passed we assume the user requested
    # the usage info and carry on as normal.
    def usage(err_msg = nil)
      if @subcommand_class
        msg = @subcommand_class.const_defined?(:USAGE) ? @subcommand_class::USAGE : ''
      else
        msg = self.class.const_defined?(:USAGE) ? self.class::USAGE : ''
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
end
