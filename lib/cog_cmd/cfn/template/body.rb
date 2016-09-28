require 'cog_cmd/cfn/helpers'
require 'json'
require 'yaml'

module CogCmd::Cfn::Template
  class Body < Cog::Command

    include CogCmd::Cfn::Helpers

    attr_reader :template_or_stack_name

    def initialize
      @template_or_stack_name = request.args[0]
    end

    def run_command
      raise(Cog::Error, "You must supply a template name OR a stack name AND the --stack option") unless template_or_stack_name

      response.template = 'template_body'
      response.content = get_template

    rescue Aws::S3::Errors::NoSuchBucket => error
      docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
      msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
      fail(msg)
    end

    private

    def get_template
      if is_stack_name?
        get_from_stack
      else
        get_from_s3
      end
    end

    def get_from_stack
      client = Aws::CloudFormation::Client.new

      resp = client.get_template(stack_name: template_or_stack_name)
      YAML.load(resp.template_body)
    end

    def get_from_s3
      client = Aws::S3::Client.new

      key = "#{template_root[:prefix]}#{template_or_stack_name}"
      resp = client.get_object(bucket: template_root[:bucket], key: key)
      YAML.load(resp.body.read)
    end

    def is_stack_name?
      request.options['stack']
    end

  end
end
