require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class Events < Cog::Command

    include CogCmd::Cfn::Helpers

    PAGE_SIZE=10

    attr_reader :stack_name

    def initialize
      # args
      @stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Abort, "You must specify a stack name.") unless stack_name

      page = request.options["page"].nil? ? 1 : request.options["page"].to_i
      events = describe_events(page) || raise(Cog::Abort, "#{self.name}: No events found for #{@stack_name} page #{page}")

      events[0]["meta"] = {
        stack_name: @stack_name,
        page: events.size < PAGE_SIZE ? "#{page} (Last)" : page
      }

      response.template = 'stack_event_list'
      response.content = events
    end

    private

    def describe_events(page)
      page = 1 if page.nil? || page < 1
      first_item = (page - 1) * PAGE_SIZE
      last_item = (first_item + PAGE_SIZE) - 1

      client = Aws::CloudFormation::Client.new

      result = client.describe_stack_events(stack_name: stack_name).stack_events
      page_results = result[first_item .. last_item]
      page_results.nil? ? nil : page_results.map(&:to_h)
    end
  end
end
