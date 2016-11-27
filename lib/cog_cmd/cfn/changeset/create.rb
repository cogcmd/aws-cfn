require 'cfn/command'
require 'cfn/ref_options'
require 'cog_cmd/cfn/changeset'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Changeset
  class Create < Cog::Command

    include Cfn::RefOptions
    include CogCmd::Cfn::Helpers

    attr_reader :changeset_name, :stack_name, :template_url, :definition,
                :description, :params, :tags, :notifications, :capabilities

    def initialize
      # args
      @stack_name = request.args[0]
      @definition = request.options['definition']

      if @definition
        require_git_client!
        require_ref_exists!
        require_definition_exists!

        definition = git_client.show_definition(@definition, { branch: 'master' })[:data]

        @stack_name = request.args[0] || definition['name']
        @template_url = definition['template_url']
        @params = merge_parameters(definition['params'])
        @tags = definition['tags']
      else
        @template_url = request.options['template_url']
        @params = merge_parameters(request.options['param'])
        @tags = process_tags(request.options['tag'])
      end

      @notifications = request.options['notify']
      @capabilities = process_capabilities(request.options['capabilities'])
      @description = request.options['description']
      @changeset_name = get_changeset_name
    end

    def run_command
      raise(Cog::Abort, "You must specify the stack name.") unless stack_name

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
        use_previous_template: @template_url.nil? ? true : false
      }.reject { |_key, value| value.nil? }

      resp = client.create_change_set(cs_params)
      client.describe_change_set(change_set_name: resp.id).to_h
    rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => ex
      cap_name = ex.message.match(/\[(?<capability>.+)\]/)[:capability]
      cap_option = cap_name.gsub(/^CAPABILITY_/, '').downcase

      response.template = "error_stack_capability"
      response.content = {
        "name": stack_name,
        "capability": cap_option
      }
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

    def use_previous_value(key)
      { parameter_key: key, use_previous_value: true }
    end

    def merge_parameters(params)
      return unless params

      client = Aws::CloudFormation::Client.new()

      # Get the current parameters from the existing stack template
      template_params = client.describe_stacks(stack_name: stack_name).first.parameters

      # Build a list of parameter names to set 'use_previous_value' for when
      # constructing the changeset
      previous_params = template_params.map { |tp| tp.parameter_key }

      params.map do |p|
        key, value = p.strip.split("=")

        # remove keys that we received in the invocation from the list of keys
        # that we use to set use_previous_value
        previous_params = previous_params - [ key ]

        { parameter_key: key, parameter_value: value }
      end + previous_params.map { |key| use_previous_value(key) }
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
    endy
  end
end
