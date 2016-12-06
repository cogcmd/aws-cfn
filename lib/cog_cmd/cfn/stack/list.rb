require 'cog_cmd/cfn/stack'
require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Stack
  class List < Cog::Command

    include CogCmd::Cfn::Helpers

    SPECIAL_FILTERS = %w(ACTIVE COMPLETE FAILED DELETED IN_PROGRESS)

    ACTIVE = %w(CREATE_IN_PROGRESS CREATE_COMPLETE ROLLBACK_IN_PROGRESS ROLLBACK_COMPLETE UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_COMPLETE UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_FAILED UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE DELETE_IN_PROGRESS ROLLBACK_FAILED DELETE_FAILED)
    COMPLETE = %w(CREATE_COMPLETE ROLLBACK_COMPLETE DELETE_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE)
    FAILED = %w(CREATE_FAILED ROLLBACK_COMPLETE ROLLBACK_FAILED DELETE_FAILED UPDATE_ROLLBACK_FAILED)
    DELETED = %w(DELETE_IN_PROGRESS DELETE_COMPLETE)
    IN_PROGRESS = %w(CREATE_IN_PROGRESS ROLLBACK_IN_PROGRESS DELETE_IN_PROGRESS UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS)

    DEFAULT_FILTERS = ACTIVE

    attr_reader :filters

    def initialize
      # options
      @filters = process_filters(request.options['filter'] || [])
    end

    def run_command
      stacks = list_stacks

      if stacks.empty?
        raise(Cog::Abort, "#{name}: No stacks found. You can use cfn:stack-create to create one.")
      end

      response.template = 'stack_list'
      response.content = stacks
    end

    private

    def list_stacks
      client = Aws::CloudFormation::Client.new
      params[:stack_status_filter] = filters unless filters.empty?
      client.list_stacks(params).stack_summaries.map(&:to_h)
    end

    # We allow the user to specify a few special shortcut filters which are just
    # collections of the basic filters allowed by cloudformation. This method
    # replaces the shortcut with the appropriate collection of cloudformation
    # templates.
    def process_filters(filters)
      filters.map do |filter|
        filter = filter.upcase
        if SPECIAL_FILTERS.include?(filter)
          self.class.const_get(filter)
        else
          filter
        end
      end.flatten.uniq
    end

  end
end
