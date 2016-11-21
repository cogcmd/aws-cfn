require 'cfn/command'
require 'cfn/ref_options'
require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Create < Cfn::Command

    include Cfn::RefOptions
    include CogCmd::Cfn::Helpers

    attr_reader :stack_name, :template_url, :definition
    attr_reader :stack_params, :tags, :policy, :notify, :on_failure, :timeout, :capabilities

    def initialize
      @definition = request.options['definition']

      if @definition
        require_git_client!
        require_ref_exists!
        require_definition_exists!

        definition = git_client.show_definition(@definition, { branch: 'master' })[:data]

        @stack_name = request.args[0] || definition['name']
        @template_url = definition['template_url']
        @stack_params = definition['params']
        @tags = definition['tags']
      else
        # args
        @stack_name = request.args[0] || @stack_name
        @template_url = request.args[1] || @template_url

        # options
        @stack_params = request.options['param']
        @tags = request.options['tag']
        @policy = request.options['policy']
        @notify = request.options['notify']
        @on_failure = request.options['on-failure']
      end

      @timeout = request.options['timeout']
      @capabilities = request.options['capabilities']
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name AND a template name.") unless stack_name
      raise(Cog::Abort, "You must specify a stack name AND a template name.") unless template_url

      response.template = 'stack_show'
      response.content = create_stack
    end

    private

    def create_stack
      client = Aws::CloudFormation::Client.new()

      params = {
        stack_name: stack_name,
        template_url: template_url,
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
    rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => ex
      cap_name = ex.message.match(/\[(?<capability>.+)\]/)[:capability]
      cap_option = cap_name.gsub(/^CAPABILITY_/, '').downcase

      response.template = "error_stack_capability"
      response.content = {
        "name": stack_name,
        "capability": cap_option
      }
    end

    def process_parameters(params)
      return unless params

      params.map do |p|
        param = p.strip.split('=')
        { parameter_key: param[0],
          parameter_value: param[1] }
      end
    end

    def require_definition_exists!
      unless git_client.definition_exists?(@definition, ref)
        if branch = ref[:branch]
          additional = "Check that the definition exists in the #{branch} branch and has been pushed to your repository's origin."
        elsif sha = ref[:tag]
          additional = "Check that the definition exists in the #{tag} tag and has been pushed to your repository's origin."
        elsif sha = ref[:sha]
          additional = "Check that the definition exists in the git commit SHA #{sha} tag and has been pushed to your repository's origin."
        end

        raise(Cog::Abort, "Definition does not exist. #{additional}")
      end
    end
  end
end
