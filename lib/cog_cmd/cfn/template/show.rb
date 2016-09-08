require_relative '../helpers'
require_relative '../exceptions'

module CogCmd::Cfn::Template
  class Show < Cog::Command
    include CogCmd::Cfn::Helpers

    USAGE = <<~END
    Usage: cfn:template show <template name> | -s <stack name>

    Shows template data.

    Options:
      --stack, -s    Specify a stack name instead of a template name

    Example:
      cfn:template show mytemplate
      ...<template summary>...

      cfn:template show -s mystack
      ...<template summary>...
    END

    def run_command
      is_stack_name = request.options['stack']

      unless request.args[0]
        msg = is_stack_name ? "You must specify a stack name or id." : "You must specify a template name."
        raise CogCmd::Cfn::ArgumentError, msg
      end

      cloudform = Aws::CloudFormation::Client.new()
      cf_params = {}
      if is_stack_name
        cf_params[:stack_name] = request.args[0]
      else
        cf_params[:template_url] = template_url(request.args[0])
      end

      cloudform.get_template_summary(cf_params).to_h
    rescue Aws::S3::Errors::NoSuchBucket => error
      docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
      msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
      fail(msg)
    end
  end
end
