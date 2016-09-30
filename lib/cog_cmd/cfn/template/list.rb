require 'cog_cmd/cfn/helpers'

module CogCmd::Cfn::Template
  class List < Cog::Command

    include  CogCmd::Cfn::Helpers

    attr_reader :template_prefix

    def initialize
      @template_prefix = request.args[0]
    end

    def run_command
      response.template = 'template_list'
      response.content = list_templates.reduce([]) do |acc, obj|
        acc.push(process_obj(obj)) if template_object?(obj)
        acc
      end

    rescue Aws::S3::Errors::NoSuchBucket => error
      docs = "#{CogCmd::Cfn::Helpers::DOCUMENTATION_URL}#configuration"
      msg = "#{error} - Make sure you have the proper url set for templates. #{docs}"
      fail(msg)
    end

    private

    def list_templates
      client = Aws::S3::Client.new()

      params = {
        bucket: template_root[:bucket],
        prefix: prefix
      }

      client.list_objects_v2(params).contents
    end

    def template_object?(obj)
      obj.key.match(/\.(json)|(ya?ml)$/)
    end

    def process_obj(obj)
      { name: strip_prefix(obj.key),
        last_modified: obj.last_modified }
    end

    def prefix
      return template_root[:prefix] unless template_prefix

      "#{template_root[:prefix]}#{template_prefix}"
    end

  end
end
