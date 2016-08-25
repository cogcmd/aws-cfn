require_relative 'helpers'
require_relative 'exceptions'

class Cog
  class AggregateCommand < Cog::Command

    include CogCmd::Cfn::Helpers

    def initialize
      subcommand = request.args.shift
      subcommands = self.class.const_get("SUBCOMMANDS")

      if subcommands.include?(subcommand)
        subcommand_class = subcommand.gsub(/(\A|_)([a-z])/) { $2.upcase }

        @subcommand = self.class.const_get(subcommand_class)
      end
    end

    def run_command
      if request.options['help']
        usage
      else
        run_subcommand
      end
    end

    private

    def subcommand
      @subcommand_inst ||= @subcommand.new(request)
    end

    def usage(err_msg = nil)
      if @subcommand
        msg = @subcommand.const_defined?(:USAGE) ? @subcommand::USAGE : ''
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
