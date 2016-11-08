module Cfn
  class Definition
    def self.create(git_client, s3_client, attributes)
      name          = attributes.fetch(:name)
      template_name = attributes.fetch(:template)
      defaults      = attributes.fetch(:defaults)
      params        = attributes.fetch(:params)
      tags          = attributes.fetch(:tags)
      branch        = attributes.fetch(:branch)

      template = git_client.show_template(template_name, { branch: branch })

      defaults = defaults.map do |d|
        default = git_client.show_defaults(d, { branch: branch })
        { 'name' => default[:name] }.merge(default[:data])
      end

      overrides = defaults.reduce({ 'params' => {}, 'tags' => {} }) do |merged, defaults|
        merged['params'].merge!(defaults['params'] || {})
        merged['tags'].merge!(defaults['tags'] || {})
        merged
      end

      params = Hash[params.map { |p| p.split('=') }]
      tags   = Hash[tags.map   { |t| t.split('=') }]

      overrides['params'].merge!(params)
      overrides['tags'].merge!(tags)

      definition = {
        'name' => name,
        'template' => {
          'name' => template_name,
          'sha' => git_client.branch_sha(branch)
        },
        'defaults' => defaults,
        'overrides' => {
          'params' => params,
          'tags' => tags
        },
        'params' => params,
        'tags' => tags
      }

      timestamp = Time.now.utc.to_i
      definition = s3_client.create_definition(name, definition, template[:data], timestamp)
      git_client.create_definition(name, definition, template[:data], timestamp, branch)

      definition
    end
  end
end
