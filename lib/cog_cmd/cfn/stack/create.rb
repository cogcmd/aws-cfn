require_relative '../exceptions'
require_relative '../helpers'

class CogCmd::Cfn::Stack::Create < Cog::SubCommand

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

  def run
    unless request.args.length >= 2
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name AND a template name."
    end

    cloudform = Aws::CloudFormation::Client.new()
    cf_params = Hash[
      [
        [ :stack_name, request.args[0] ],
        [ :template_url, template_url(request.args[1]) ],
        param_or_nil([ :parameters, process_parameters(request.options["param"]) ]),
        param_or_nil([ :tags, process_tags(request.options["tag"]) ]),
        param_or_nil([ :stack_policy_url, policy_url(request.options["policy"]) ]),
        param_or_nil([ :notification_arns, request.options["notify"] ]),
        param_or_nil([ :on_failure, process_on_failure(request.options["on-failure"]) ]),
        param_or_nil([ :timeout_in_minutes, request.options["timeout"] ]),
        param_or_nil([ :capabilities, process_capabilities(request.options["capabilities"]) ])
      ].compact
    ]

    cloudform.create_stack(cf_params)
    cloudform.describe_stacks(stack_name: request.args[0]).stacks[0].to_h
  end

end
