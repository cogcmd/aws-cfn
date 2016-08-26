require_relative '../exceptions'
require_relative '../helpers'

class CogCmd::Cfn::Template::Show < Cog::SubCommand

  include CogCmd::Cfn::Helpers

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:template show <template name> | -s <stack name>

  Options:
    --stack, -s    "Specify a stack name instead of a template name"

  Example:
    cfn:template show mytemplate
    ...<template summary>...

    cfn:template show -s mystack
    ...<template summary>...
  END

  def run
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
  end
end
