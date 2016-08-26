require_relative '../helpers'

class CogCmd::Cfn::Stack::List < Cog::SubCommand

  include CogCmd::Cfn::Helpers

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack list [options]

  List stack summaries

  Options:
    --filter "status filter"    (Can be specified multiple times) (Defaults to 'ACTIVE')
    --limit <int>

  Notes:
    The filter string can be one or more cloudformation stack status strings which include:
    CREATE_IN_PROGRESS, CREATE_FAILED, CREATE_COMPLETE, ROLLBACK_IN_PROGRESS, ROLLBACK_FAILED, ROLLBACK_COMPLETE, DELETE_IN_PROGRESS, DELETE_FAILED, DELETE_COMPLETE, UPDATE_IN_PROGRESS, UPDATE_COMPLETE_CLEANUP_IN_PROGRESS, UPDATE_COMPLETE, UPDATE_ROLLBACK_IN_PROGRESS, UPDATE_ROLLBACK_FAILED, UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS, UPDATE_ROLLBACK_COMPLETE

    Additionally a few special filter strings that correspond to a subset of the standard filter strings may be used:
    ACTIVE, COMPLETE, FAILED, DELETED, IN_PROGRESS
  END

  SPECIAL_FILTERS = %w(ACTIVE COMPLETE FAILED DELETED IN_PROGRESS)

  ACTIVE = %w(CREATE_IN_PROGRESS CREATE_COMPLETE ROLLBACK_IN_PROGRESS ROLLBACK_COMPLETE UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_COMPLETE UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_FAILED UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE)
  COMPLETE = %w(CREATE_COMPLETE ROLLBACK_COMPLETE DELETE_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE)
  FAILED = %w(CREATE_FAILED ROLLBACK_COMPLETE ROLLBACK_FAILED DELETE_FAILED UPDATE_ROLLBACK_FAILED)
  DELETED = %w(DELETE_IN_PROGRESS DELETE_COMPLETE)
  IN_PROGRESS = %w(CREATE_IN_PROGRESS ROLLBACK_IN_PROGRESS DELETE_IN_PROGRESS UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS)

  def run
    cloudform = Aws::CloudFormation::Client.new()
    cf_params = {}

    filters = request.options['filter'] || ['ACTIVE']
    cf_params[:stack_status_filter] = process_filters(filters)

    stack_summaries = cloudform.list_stacks(cf_params).stack_summaries

    if limit = request.options['limit'].to_i
      stack_summaries.slice(0, limit).map(&:to_h)
    else
      stack_summaries.map(&:to_h)
    end
  end

  private

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
