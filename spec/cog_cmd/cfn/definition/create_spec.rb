require 'spec_helper'

require 'cog_cmd/cfn/definition/create'
require 'cfn/git_client'
require 'cfn/s3_client'
require 'cfn/cfn_client'
require 'cfn/definition'

describe CogCmd::Cfn::Definition::Create do
  let(:command_name) { 'definition-create' }
  let(:git_client) { double(Cfn::GitClient) }
  let(:s3_client) { double(Cfn::S3Client) }
  let(:cfn_client) { double(Cfn::CfnClient) }

  before do
    allow(Cfn::GitClient).to receive(:new).and_return(git_client)
    allow(Cfn::S3Client).to receive(:new).and_return(s3_client)
    allow(Cfn::CfnClient).to receive(:new).and_return(cfn_client)
  end

  context 'with valid args, options, and env' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
      allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return('AKIBU34Z8KYDVRZKWRTQ')
      allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return('YQ7h84BCvE4fJhT1TdOzOgO8zpAIbulblb6MCHkO')
      allow(ENV).to receive(:[]).with('S3_STACK_DEFINITION_BUCKET').and_return('cfn-bundle-files')
    end

    it 'creates a definition' do
      definition = {
        'name' => 'flywheel',
        'template' => {
          'name' => 'ec2',
          'sha' => 'f10277dc76591d6215638ebfba4e52133682a075'
        },
        'defaults' => [{
          'name' => 'webapp',
          'params' => {
            'port' => 80
          },
          'tags' => {}
        }, {
          'name' => 'staging',
          'params' => {
            'env' => 'staging'
          },
          'tags' => {}
        }],
        'overrides' => {
          'params' => {
            'port' => 80,
            'env' => 'staging'
          },
          'tags' => {}
        },
        'params' => {},
        'tags' => {} 
      }

      expect(git_client).to receive(:template_exists?).
        with('ec2', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:defaults_exists?).
        with('webapp', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:defaults_exists?).
        with('staging', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:branch_exists?).
        with('master').
        and_return(true)

      expect(Cfn::Definition).to receive(:create).
        with(git_client, s3_client, cfn_client, {
          name: 'flywheel',
          template: 'ec2',
          defaults: ['webapp', 'staging'],
          params: [],
          tags: [],
          branch: 'master'
        }).
        and_return(definition)

      run_command(args: ['flywheel', 'ec2'], options: { defaults: ['webapp', 'staging'], params: [], tags: [] })

      expect(command).to respond_with([definition])
    end
  end

  context 'with invalid git env' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return('AKIBU34Z8KYDVRZKWRTQ')
      allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return('YQ7h84BCvE4fJhT1TdOzOgO8zpAIbulblb6MCHkO')
      allow(ENV).to receive(:[]).with('S3_STACK_DEFINITION_BUCKET').and_return('cfn-bundle-files')
    end

    it 'returns an error if missing git env vars' do
      expect {
        run_command(args: ['flywheel', 'ec2'])
      }.to raise_error(Cog::Abort, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
    end
  end

  context 'with invalid args' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
      allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return('AKIBU34Z8KYDVRZKWRTQ')
      allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return('YQ7h84BCvE4fJhT1TdOzOgO8zpAIbulblb6MCHkO')
      allow(ENV).to receive(:[]).with('S3_STACK_DEFINITION_BUCKET').and_return('cfn-bundle-files')
    end

    it 'returns an error if missing name' do
      expect {
        run_command(args: [])
      }.to raise_error(Cog::Abort, 'Name not provided. Provide a name as the first argument.')
    end

    it 'returns an error if invalid name is passed' do
      expect {
        run_command(args: ['! # l #'])
      }.to raise_error(Cog::Abort, 'Name must only include word characters [a-zA-Z0-9_-].')
    end

    it 'returns an error if the template does not exist' do
      expect(git_client).to receive(:branch_exists?).
        with('master').
        and_return(true)

      expect(git_client).to receive(:template_exists?).
        with('ec2', branch: 'master').
        and_return(false)

      expect {
        run_command(args: ['flywheel', 'ec2'])
      }.to raise_error(Cog::Abort, 'Template does not exist. Check that the template exists in the master branch and has been pushed to your repository\'s origin.')
    end
  end

  context 'with invalid options' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
      allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return('AKIBU34Z8KYDVRZKWRTQ')
      allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return('YQ7h84BCvE4fJhT1TdOzOgO8zpAIbulblb6MCHkO')
      allow(ENV).to receive(:[]).with('S3_STACK_DEFINITION_BUCKET').and_return('cfn-bundle-files')
    end

    it 'returns an error if the provided branch does not exist' do
      expect(git_client).to receive(:branch_exists?).
        with('dev').
        and_return(false)

      expect {
        run_command(args: ['flywheel', 'ec2'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Branch dev does not exist. Create a branch, push it to your repository\'s origin, and try again.')
    end

    it 'returns an error if any of the provided defaults do not exist' do
      expect(git_client).to receive(:branch_exists?).
        with('master').
        and_return(true)

      expect(git_client).to receive(:template_exists?).
        with('ec2', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:defaults_exists?).
        with('webapp', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:defaults_exists?).
        with('staging', branch: 'master').
        and_return(false)

      expect {
        run_command(args: ['flywheel', 'ec2'], options: { 'defaults' => ['webapp', 'staging'] })
      }.to raise_error(Cog::Abort, 'Defaults file staging does not exist. Check that the defaults file exists in the master branch and has been pushed to your repository\'s origin.')
    end
  end
end
