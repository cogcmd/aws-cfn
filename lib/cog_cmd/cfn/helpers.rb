require 'aws-sdk'
require 'cog/command'
require_relative 'exceptions'

# If an AWS STS ROLE is defined, configure the AWS SDK to assume it
if ENV['AWS_STS_ROLE_ARN']
  Aws.config.update(
    credentials: Aws::AssumeRoleCredentials.new(
      role_arn: ENV['AWS_STS_ROLE_ARN'],
      role_session_name: "cog-#{ENV['COG_USER']}"
    )
  )
end

module CogCmd::Cfn::Helpers

  DOCUMENTATION_URL = "https://github.com/cogcmd/aws-cfn"

  def strip_prefix(str)
    str.sub(template_root[:prefix], "")
  end

  def strip_json(str)
    str.sub(/\.json$/, "")
  end

  def template_root
    parse_s3_url(cfn_template_url)
  end

  def policy_root
    parse_s3_url(cfn_policy_url)
  end

  def template_url(template_name)
    return unless template_name

    [ "https://#{template_root['bucket']}.s3.amazonaws.com",
      "#{template_root['prefix']}#{template_name}.json" ].join('/')
  end

  def policy_url(policy_name)
    return nil if policy_name.nil?

    [ "https://#{policy_root['bucket']}.s3.amazonaws.com",
      "#{policy_root['prefix']}#{policy_name}.json" ].join('/')
  end

  def param_or_nil(param)
    return if param[1] == nil
    param
  end

  def process_tags(tags)
    return unless tags
    tags.map do |t|
      tag = t.strip.split("=")
      { key: tag[0],
        value: tag[1] }
    end
  end

  def process_on_failure(on_failure)
    return unless on_failure

    case on_failure.upcase
    when "KEEP"
      "DO_NOTHING"
    when "DO_NOTHING"
      "DO_NOTHING"
    when "ROLLBACK"
      "ROLLBACK"
    when "DELETE"
      "DELETE"
    else
      fail("Unknown action '#{on_failure}' for --on-failure. Must be one of ['KEEP', 'ROLLBACK', 'DELETE']")
    end
  end

  def process_capabilities(capabilities)
    return unless capabilities

    capabilities.map { |c| capability(c) }.compact
  end

  def error(msg)
    "cfn: Error: #{msg}"
  end

  def access_denied_msg
    <<-END.gsub(/^ {3}|\n/, '')
    Access Denied. Make sure that you have the proper permissions with AWS
    to create a CloudFormation stack, and that your credentials have been
    configured properly with Cog. #{DOCUMENTATION_URL}#configuration
    END
  end

  def usage(msg, err_msg = nil)
    if err_msg
      "```#{msg}```\n#{error(err_msg)}"
    else
      "```#{msg}```"
    end
  end

  private

  def capability(cp)
    return unless cp

    case cp.upcase
    when "IAM"
      "CAPABILITY_IAM"
    when "NAMED_IAM"
      "CAPABILITY_NAMED_IAM"
    else
      fail("Unknown capability '#{cp}'. Must be one of ['IAM', 'NAMED_IAM']")
    end
  end

  def parse_s3_url(url)
    url.match(/((?<scheme>[^:]+):\/\/)?(?<bucket>[^\/]+)\/(?<prefix>.*)/)
  end

  def cfn_template_url
    if template_url = ENV['CFN_TEMPLATE_URL']
      append_slash(template_url)
    else
      raise CogCmd::Cfn::EnvVarError, "Required environment variable 'CFN_TEMPLATE_URL' missing"
    end
  end

  def cfn_policy_url
    if policy_url = ENV['CFN_POLICY_URL']
      append_slash(policy_url)
    else
      raise CogCmd::Cfn::EnvVarError, "Required environment variable 'CFN_POLICY_URL' missing"
    end
  end

  # So things will be consitant we add a slash to the end of cfn urls if one
  # doesn't already exist
  def append_slash(url)
    if url.end_with?("/")
      url
    else
      "#{url}/"
    end
  end
end
