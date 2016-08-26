# Cog::SubCommand is the parent class for subcommands. Subcommands are used
# in tandem with Cog::AggregateCommand. Subcommands are required to define a
# method 'run' that is invoked when the subcommand is executed, and the constant
# USAGE where the usage info for the subcommand is stored.
class Cog
  class SubCommand

    def initialize(request)
      @request = request
    end

    private

    def request
      @request
    end

  end
end
