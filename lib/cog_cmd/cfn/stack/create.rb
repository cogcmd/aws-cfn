require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Create < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :stack_name, :template_name
    attr_reader :stack_params, :tags, :policy, :notify, :on_failure, :timeout, :capabilities

    def initialize
      # args
      @stack_name = request.args[0]
      @template_name = request.args[1]

      # options
      @stack_params = request.options['param']
      @tags = request.options['tag']
      @policy = request.options['policy']
      @notify = request.options['notify']
      @on_failure = request.options['on-failure']
      @timeout = request.options['timeout']
      @capabilities = request.options['capabilities']
    end

    def run_command
      raise(CogCmd::Cfn::ArgumentError, "You must specify a stack name AND a template name.") unless stack_name
      raise(CogCmd::Cfn::ArgumentError, "You must specify a stack name AND a template name.") unless template_name

      response.template = 'stack_show'
      response.content = create_stack
    end

    private

    def create_stack
      client = Aws::CloudFormation::Client.new()

      params = {
        stack_name: stack_name,
        template_url: template_url(template_name),
        parameters: process_parameters(stack_params),
        tags: process_tags(tags),
        stack_policy_url: policy_url(policy),
        notification_arns: notify,
        on_failure: process_on_failure(on_failure),
        timeout_in_minutes: timeout,
        capabilities: process_capabilities(capabilities)
      }.reject { |_key, value| value.nil? }

      client.create_stack(params)
      client.describe_stacks(stack_name: stack_name).stacks[0].to_h
    end

    def process_parameters(params)
      return nil unless params

      params.map do |p|
        param = p.strip.split('=')
        { parameter_key: param[0],
          parameter_value: param[1] }
      end
    end

  end
end
