require_relative '../exceptions'
require_relative '../helpers'

class CogCmd::Cfn::Stack::Create < Cog::Command

  include CogCmd::Cfn::Helpers

  USAGE = <<~END
  Usage: cfn:stack create <stack name> <template name> [options]

  Creates a new stack based on an existing template and returns the newly created stack.

  Options:
    --param, -p "Key1=Value1"                   (Can be specified multiple times)
    --tag, -t "Name1=Value1"                    (Can be specified multiple times)
    --policy, -o "s3_policy_name"
    --notify, -n "NotifyArn"                    (Can be specified multiple times)
    --on-failure, -f <rollback | delete | keep>
    --timeout, -e <minutes>
    --capabilities, -c <iam | named_iam>
  END

  def run_command
    unless stack_name = request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name AND a template name."
    end

    unless template_name = request.args[1]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name AND a template name."
    end

    client = Aws::CloudFormation::Client.new()

    cf_params = Hash[
      [
        [ :stack_name, stack_name ],
        [ :template_url, template_url(template_name) ],
        param_or_nil([ :parameters, process_parameters(request.options["param"]) ]),
        param_or_nil([ :tags, process_tags(request.options["tag"]) ]),
        param_or_nil([ :stack_policy_url, policy_url(request.options["policy"]) ]),
        param_or_nil([ :notification_arns, request.options["notify"] ]),
        param_or_nil([ :on_failure, process_on_failure(request.options["on-failure"]) ]),
        param_or_nil([ :timeout_in_minutes, request.options["timeout"] ]),
        param_or_nil([ :capabilities, process_capabilities(request.options["capabilities"]) ])
      ].compact
    ]

    client.create_stack(cf_params)
    client.describe_stacks(stack_name: stack_name).stacks[0].to_h
  end

  private

  def process_parameters(params)
    params.map do |p|
      param = p.strip.split('=')
      { parameter_key: param[0],
        parameter_value: param[1] }
    end
  end

end
