require 'spec_helper'

require 'open3'
require 'aws-sdk'
require 'rugged'

describe 'creating a definition', feature: true do
  it 'stores the definition in S3 and commits it to the git repo' do
    command_path = File.join(Dir.pwd, 'cog-command')

    name = 'replicated'
    template = 'replicated'

    env = { 'COG_COMMAND'                => 'definition-create',
            'COG_SERVICES_ROOT'          => 'http://localhost:4002',
            'GIT_REMOTE_URL'             => ENV['GIT_REMOTE_URL'],
            'GIT_SSH_KEY'                => File.read(ENV['GIT_SSH_KEY_PATH']),
            'AWS_ACCESS_KEY_ID'          => ENV['AWS_ACCESS_KEY_ID'],
            'AWS_SECRET_ACCESS_KEY'      => ENV['AWS_SECRET_ACCESS_KEY'],
            'S3_STACK_DEFINITION_BUCKET' => ENV['S3_STACK_DEFINITION_BUCKET'],
            'COG_ARGC'                   => '2',
            'COG_ARGV_0'                 => name,
            'COG_ARGV_1'                 => template,
            'COG_OPTS'                   => 'defaults,params,tags',
            'COG_OPT_DEFAULTS_COUNT'     => '1',
            'COG_OPT_PARAMS_COUNT'       => '1',
            'COG_OPT_TAGS_COUNT'         => '2',
            'COG_OPT_DEFAULTS_0'         => 'replicated-stage',
            'COG_OPT_PARAMS_0'           => 'SshKey=imbriaco',
            'COG_OPT_TAGS_0'             => 'CreatedBy=aws-cfn',
            'COG_OPT_TAGS_1'             => 'AuthoredBy=vanstee' }

    out, err, ps = Open3.capture3(env, command_path, { stdin_data: '[{}]' })

    output = <<~OUTPUT
      COG_TEMPLATE: definition_create
      JSON
      [{"name":"replicated","template":{"name":"replicated","sha":"~wildcard~"},"defaults":[{"name":"replicated-stage","params":{"VpcId":"vpc-194bce193","SubnetId":"subnet-a823409c","InstanceType":"t2.small"},"tags":{"Env":"stage"}}],"overrides":{"params":{"SshKey":"imbriaco"},"tags":{"CreatedBy":"aws-cfn","AuthoredBy":"vanstee"}},"params":{"SshKey":"imbriaco"},"tags":{"CreatedBy":"aws-cfn","AuthoredBy":"vanstee"},"template_url":"https://s3.amazonaws.com/cogcmd-aws-cfn-test/definition/replicated/~timestamp~/template.yaml"}]
    OUTPUT

    output_regexp_string = Regexp.escape(output).gsub('~wildcard~', '.*').gsub('~timestamp~', '(?<timestamp>.*)')
    output_regexp = Regexp.new(output_regexp_string, Regexp::MULTILINE)

    expect(out).to match(output_regexp)
    expect(ps.exitstatus).to eq(0)
    expect(err).to eq('')

    match = output_regexp.match(out)

    client = Aws::S3::Client.new(access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
                                 secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])

    s3_files = client.list_objects_v2(bucket: ENV['S3_STACK_DEFINITION_BUCKET']).contents.map(&:to_h)

    s3_definition = s3_files.find { |f| f[:key] = "definition/replicated/#{match[:timestamp]}/definition.yaml" }
    s3_template   = s3_files.find { |f| f[:key] = "definition/replicated/#{match[:timestamp]}/template.yaml" }

    expect(s3_definition).to be
    expect(s3_template).to be

    git_credential = Rugged::Credentials::SshKey.new(
      username: 'git',
      privatekey: ENV['GIT_SSH_KEY_PATH']
    )

    repository = Rugged::Repository.clone_at(
      ENV['GIT_REMOTE_URL'],
      Dir.mktmpdir,
      credentials: git_credential
    )

    definition_path = File.join(repository.workdir, "definitions/replicated/#{match[:timestamp]}/definition.yaml")
    template_path   = File.join(repository.workdir, "definitions/replicated/#{match[:timestamp]}/template.yaml")

    expect(File.exist?(definition_path)).to be_truthy
    expect(File.exist?(template_path)).to be_truthy
  end
end
