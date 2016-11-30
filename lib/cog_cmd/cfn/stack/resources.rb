require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Resources < Cog::Command

    attr_reader :stack_name

    PAGE_SIZE=10

    def initialize
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name.") unless stack_name

      page = request.options["page"].nil? ? 1 : request.options["page"].to_i
      resources = list_resources(page) || raise(Cog::Abort, "#{self.name}: No resources found for #{@stack_name} page #{page}")

      resources.first["meta"] = {
        stack_name: @stack_name,
        page: resources.size < PAGE_SIZE ? "#{page} (Last)" : page
      }

      response.template = 'stack_resource_list'
      response.content = resources
    end

    private

    def list_resources(page)
      page = 1 if page.nil? || page < 1
      first_item = (page - 1) * PAGE_SIZE
      last_item = (first_item + PAGE_SIZE) - 1

      client = Aws::CloudFormation::Client.new

      result = client.list_stack_resources(stack_name: stack_name).stack_resource_summaries
      page_results = result[first_item .. last_item]
      page_results.nil? ? nil : page_results.map(&:to_h)
    end

  end
end
