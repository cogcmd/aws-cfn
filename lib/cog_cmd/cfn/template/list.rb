require_relative 'base'

module CogCmd::Cfn::Template
  class List < Base
    USAGE = <<~END
    Usage: cfn:template list

    Lists cloudformation templates in the configured s3 bucket.
    END

    def run_command
      s3 = Aws::S3::Client.new()

      objects = s3.list_objects_v2(bucket: template_root[:bucket], prefix: template_root[:prefix]).contents
      results =
        objects.find_all do |obj|
          obj.key.end_with?(".json")
        end.map do |obj|
          { "name": strip_json(strip_prefix(obj.key)),
            "last_modified": obj.last_modified }
        end

      response.template = 'template_table'
      response.content = results
    end
  end
end
