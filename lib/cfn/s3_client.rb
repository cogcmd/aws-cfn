require 'aws-sdk'
require 'digest'
require 'time'

module Cfn
  class S3Client
    attr_reader :client, :bucket, :prefix

    def initialize(bucket, prefix, aws_sts_role_arn = nil)
      update_aws_credentials(aws_sts_role_arn) if aws_sts_role_arn

      @client = Aws::S3::Client.new
      @prefix = prefix
      @bucket = bucket
    end

    def create_definition(name, definition, template, timestamp)
      path = "definition/#{name}/#{timestamp}"
      template_path = "#{path}/template.yaml"
      definition_path = "#{path}/definition.yaml"

      definition['template_url'] = url_for(template_path)

      create_file(template_path, template)
      create_file(definition_path, definition.to_yaml)

      definition
    end

    def bucket_exists?
      @client.head_bucket(bucket: @bucket)
    end

    def create_temp_file(content)
      name = Digest::SHA256.base64digest(content)
      path = "tmp/#{name}"
      create_file(path, content)
      url_for(path)
    end

    private

    # TODO: Handle listing over continuation (pagination)
    def list_files(bucket=@bucket)
      response = @client.list_objects_v2(bucket: bucket)
      response.contents
    end

    def create_file(key, body, params = {})
      key = "#{prefix}/#{key}" unless prefix.nil?
      params.merge!(bucket: bucket, key: key)

      put_params = params.merge(body: body)
      @client.put_object(put_params)

      acl_params = params.merge(acl: "bucket-owner-full-control")
      @client.put_object_acl(acl_params)

      params
    end

    def info_file(key, params = {})
      params.merge!(bucket: bucket, key: key)
      response = @client.get_object(params)
      body = response.body.read
      { bucket: bucket, key: key, body: body }
    end

    def destroy_file(key, params = {})
      params.merge!(bucket: bucket, key: key)
      @client.delete_object(params)
      params
    end

    def url_for(path)
      path = "#{prefix}/#{path}" unless prefix.nil?
      "https://s3.amazonaws.com/#{bucket}/#{path}"
    end

    def update_aws_credentials(aws_sts_role_arn)
      Aws.config.update(
        credentials: Aws::AssumeRoleCredentials.new(
          role_arn: aws_sts_role_arn,
          role_session_name: "cog-#{ENV['COG_USER']}"
        )
      )
    end
  end
end
