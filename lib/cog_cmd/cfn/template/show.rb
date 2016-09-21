require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Template
  class Show < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :template_or_stack_name

    def initialize
      # args
      @template_or_stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Error, bad_arg_msg) unless @template_or_stack_name

      client = Aws::CloudFormation::Client.new()
      cf_params = {}
      if is_stack_name?
        cf_params[:stack_name] = template_or_stack_name
      else
        cf_params[:template_url] = template_url(template_or_stack_name)
      end

      results = client.get_template_summary(cf_params).to_h
      results.merge!({ "source": cf_params[:template_url] || cf_params[:stack_name] })

      response.template = "template_show"
      response.content = results
    end

    private

    def is_stack_name?
      request.options['stack']
    end

    def bad_arg_msg
      if is_stack_name?
        "You must specify a stack name or id." 
      else
        "You must specify a template name."
      end
    end
  end
end
