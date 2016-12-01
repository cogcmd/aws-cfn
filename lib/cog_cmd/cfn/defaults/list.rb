require 'cog_cmd/cfn/defaults'
require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Defaults
  class List < Cfn::Command
    include Cfn::RefOptions

    def run_command
      require_git_client!
      require_ref_exists!

      defaults = git_client.list_defaults(filter, ref)

      if defaults.empty?
        raise(Cog::Abort, "#{name}: No defaults found. You can use cfn:defaults-create to create some.")
      end

      response.template = 'defaults_list'
      response.content = defaults
    end

    def filter
      request.args[0] || '*'
    end
  end
end
