require 'cog/command'

module CogCmd::Cfn::Helpers
  def strip_prefix(str)
    str.sub(template_url[:prefix], "")
  end

  def strip_json(str)
    str.sub(/\.json$/, "")
  end

  def template_url
    url = env_var("CFN_TEMPLATE_URL", required: true)
    url.match(/((?<scheme>[^:]+):\/\/)?(?<bucket>[^\/]+)\/(?<prefix>.*)/)
  end
end
