require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class Create < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :stack_name
    attr_reader :params, :tags, :notifications, :capabilities, :description, :changeset_name

    def initialize
      # args
      @stack_name = request.args[0]

      # options
      @params = merge_parameters(request.options['param'])
      @tags = process_tags(request.options['tag'])
      @notifications = request.options['notify']
      @capabilities = process_capabilities(request.options['capabilities'])
      @description = request.options['description']
      @changeset_name = get_changeset_name
    end

    def run_command
      raise(Cog::Error, "You must specify the stack name.") unless stack_name

      response.template = 'changeset_show'
      response.content = create_changeset
    end

    private

    def create_changeset
      client = Aws::CloudFormation::Client.new()

      cs_params = {
        stack_name: stack_name,
        change_set_name: changeset_name,
        parameters: params,
        tags: tags,
        notification_arns: notifications,
        capabilities: capabilities,
        description: description,
        # Changing the template can muck up parameters. For now we'll always
        # use the previous template. We can revisit and adjust how we deal with
        # params later if needed.
        use_previous_template: true
      }.reject { |_key, value| value.nil? }

      resp = client.create_change_set(cs_params)
      client.describe_change_set(change_set_name: resp.id).to_h
    end

    def get_changeset_name
      # If the user specifies a changeset-name just return that
      return request.options['changeset-name'] if request.options['changeset-name']

      # If the user doesn't specify a changeset-name then we generate one based on the number
      # of changesets already created.
      client = Aws::CloudFormation::Client.new()
      num_of_changesets = client.list_change_sets({ stack_name: stack_name }).summaries.length

      "changeset#{num_of_changesets}"
    end

    def merge_parameters(params)
      client = Aws::CloudFormation::Client.new()

      # Grab the original template to merge the new params
      template_params = client.get_template_summary(stack_name: stack_name).parameters

      params ||= []
      params = params.map do |p|
        param = p.strip.split("=")
        { parameter_key: param[0],
          parameter_value: param[1] }
      end

      template_params.map do |tp|
        param = { parameter_key: tp.parameter_key }

        if val = params.find { |p| p[:parameter_key] == tp.parameter_key }
          param[:parameter_value] = val[:parameter_value]
        else
          param[:use_previous_value] = true
        end

        param
      end
    end

  end
end
