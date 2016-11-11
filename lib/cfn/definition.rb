module Cfn
  class Definition
    def self.create(git_client, s3_client, attributes)
      new(attributes).create(git_client, s3_client)
    end

    def initialize(attributes)
      @definition_name = attributes.fetch(:name)
      @template_name   = attributes.fetch(:template)
      @defaults_names  = attributes.fetch(:defaults)
      @params          = attributes.fetch(:params)
      @tags            = attributes.fetch(:tags)
      @branch          = attributes.fetch(:branch)
    end

    def create(git_client, s3_client)
      template = fetch_template(git_client)
      defaults = fetch_defaults(git_client)
      sha = git_client.branch_sha(@branch)

      definition = {
        'name' => @definition_name,
        'template' => {
          'name' => @template_name,
          'sha' => sha
        },
        'defaults' => defaults,
        'overrides' => overrides(defaults),
        'params' => @params,
        'tags' => @tags
      }

      timestamp = Time.now.utc.to_i

      definition = s3_client.create_definition(@definition_name, definition, template, timestamp)
      git_client.create_definition(@definition_name, definition, template, timestamp, @branch)

      definition
    end

    def fetch_template(git_client)
      git_client.show_template(@template_name, { branch: @branch })[:data]
    end

    def fetch_defaults(git_client)
      @defaults_names.map do |default_name|
        default = git_client.show_defaults(default_name, { branch: @branch })
        { 'name' => default[:name] }.merge(default[:data])
      end
    end

    def override_layers(defaults)
      defaults + [{ 'params' => params_hash, 'tags' => tags_hash }]
    end

    def overrides(defaults)
      override_layers(defaults).reduce({ 'params' => {}, 'tags' => {} }) do |merged, layer|
        merged['params'].merge!(layer['params'] || {})
        merged['tags'].merge!(layer['tags'] || {})
        merged
      end
    end

    def params_hash
      Hash[@params.map { |p| p.split('=') }]
    end

    def tags_hash
      Hash[@tags.map { |t| t.split('=') }]
    end
  end
end
