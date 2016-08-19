require 'aws-sdk'
require 'cog/command'

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
  def strip_prefix(str)
    str.sub(template_root[:prefix], "")
  end

  def strip_json(str)
    str.sub(/\.json$/, "")
  end

  def template_root
    cfn_template_url.match(/((?<scheme>[^:]+):\/\/)?(?<bucket>[^\/]+)\/(?<prefix>.*)/)
  end

  def template_url(template_name)
    "#{cfn_template_url}#{template_name}.json"
  end

  def policy_url(policy_name)
    "#{cfn_policy_url}#{policy_name}.json"
  end

  private

  def cfn_template_url
    append_slash(env_var("CFN_TEMPLATE_URL", required: true))
  end

  def cfn_policy_url
    append_slash(env_var("CFN_POLICY_URL", required: true))
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
