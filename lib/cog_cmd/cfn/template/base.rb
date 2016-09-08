require_relative '../exceptions'
require_relative '../helpers'

module CogCmd::Cfn::Template
  class Base < Cog::Command
    include CogCmd::Cfn::Helpers

    def run_command
      super
    rescue Aws::S3::Errors::NoSuchBucket => error
      docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
      msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
      fail(msg)
    end
  end
end
