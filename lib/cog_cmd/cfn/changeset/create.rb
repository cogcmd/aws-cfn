class CogCmd::Cfn::Changeset < Cog::Command
  module Create

    USAGE = <<-END.gsub(/^ {4}/, '')
    Usage: cfn:changeset create <stack name> [options]

    Options:
      --param, -p "Key1=Value1"               (Can be specified multiple times)
      --tag, -t "Name1=Value1"                (Can be specified multiple times)
      --template, -m "TemplateName"           (defaults to UsePreviousTemplate)
      --notify, -n "NotifyArn"                (Can be specified multiple times)
      --capabilities, -c <iam | named_iam>
      --description, -d "Description"
      --changeset-name "ChangesetName"        (Defaults to 'changeset<num>')

    Examples:
      cfn:changeset create mystack --param "Key1=Value1" --param "Key2=Value2"
    END

  end

  def create(client, request)
    stack_name = request.args[1]

    changesets = client.list_change_sets({ stack_name: stack_name }).summaries
    changeset_name = request.options['changeset-name'] || "changeset#{changesets.length}"
    # Checking the template name and setting it accordingly. If a user passes 'UsePreviousTemplate' they
    # should get their expected results now.
    scanner = StringScanner.new(request.options['template'] || '')
    template_name = scanner.match?(/UsePreviousTemplate/i) ? nil : request.options['template']

    cs_params = Hash[
      [
        [ :stack_name, stack_name ],
        [ :use_previous_template, template_name ? false : true ],
        [ :change_set_name, changeset_name ],
        param_or_nil([ :template_url, template_url(template_name) ]),
        param_or_nil([ :parameters, get_parameters(request.options['param']) ]),
        param_or_nil([ :tags, get_tags(request.options['tag']) ]),
        param_or_nil([ :notification_arns, request.options['notify'] ]),
        param_or_nil([ :capabilities, get_capabilities(request.options['capabilities']) ]),
        param_or_nil([ :description, request.options['description'] ])
      ].compact
    ]

    client.create_change_set(cs_params).to_h
  end
end
