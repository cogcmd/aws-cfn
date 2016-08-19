#!/usr/bin/env ruby

require_relative 'helpers'

class CogCmd::Cfn::Template < Cog::Command

  include CogCmd::Cfn::Helpers

  def run_command
    case request.args[0]
    when "list"
      list
    when "describe"
      describe
    else
      usage
    end
  end

  private

  def usage
    response["body"] = "Usage: cfn:template < list | describe <name> >"
  end

  def list
    s3 = Aws::S3::Client.new()
    templates = s3.list_objects_v2(bucket: template_root[:bucket], prefix: template_root[:prefix])
                .contents
                .find_all { |obj|
                  obj.key.end_with?(".json")
                }
                .map { |obj|
                  { "name": strip_json(strip_prefix(obj.key)),
                    "last_modified": obj.last_modified }
                }

    response.content = {
      "templates": templates
    }
  end

  def describe
    response.content = {
      "parameters": []
    }
  end
end
