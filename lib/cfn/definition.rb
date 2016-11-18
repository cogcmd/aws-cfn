module Cfn
  class Definition
    def self.create(git_client, s3_client, cfn_client, attributes)
      new(attributes).create(git_client, s3_client, cfn_client)
    end

    def initialize(attributes)
      @definition_name = attributes.fetch(:name)
      @template_name   = attributes.fetch(:template)
      @defaults_names  = attributes.fetch(:defaults) || []
      @params          = attributes.fetch(:params) || {}
      @tags            = attributes.fetch(:tags) || {}
      @branch          = attributes.fetch(:branch)
    end

    def create(git_client, s3_client, cfn_client)
      template = fetch_template(git_client)
      defaults = fetch_defaults(git_client)
      sha = git_client.branch_sha(@branch)
      merged = merge_overrides(defaults)

      definition = {
        'name' => @definition_name,
        'template' => {
          'name' => @template_name,
          'sha' => sha
        },
        'defaults' => defaults,
        'overrides' => params_hash,
        'params' => hash_to_kv(merged['params']),
        'tags' => hash_to_kv(merged['tags'])
      }

      cfn_client.validate_template(template[:body])

      timestamp = Time.now.utc.to_i
      definition = s3_client.create_definition(@definition_name, definition, template[:data], timestamp)
      git_client.create_definition(@definition_name, definition, template[:data], timestamp, @branch)

      definition
    end

    def fetch_template(git_client)
      git_client.show_template(@template_name, { branch: @branch })
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

    def merge_overrides(defaults)
      override_layers(defaults).reduce({ 'params' => {}, 'tags' => {} }) do |merged, layer|
        merged['params'].merge!(layer['params'] || {})
        merged['tags'].merge!(layer['tags'] || {})
        merged
      end
    end

    def params_hash
      kv_to_hash(@params)
    end

    def tags_hash
      kv_to_hash(@tags)
    end

    def hash_to_kv(hash)
      hash.to_a.map { |i| i.join("=") }
    end

    def kv_to_hash(kv)
      Hash[kv.map { |t| t.split('=') }]
    end
  end
end
