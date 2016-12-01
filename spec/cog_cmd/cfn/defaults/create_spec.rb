require 'spec_helper'

require 'cog_cmd/cfn/defaults/create'
require 'cfn/git_client'

describe CogCmd::Cfn::Defaults::Create do
  let(:command_name) { 'defaults-create' }
  let(:cog_env) { [{ 'params' => { 'port' => 80 } }] }
  let(:git_client) { double(Cfn::GitClient) }

  before do
    allow(Cfn::GitClient).to receive(:new).and_return(git_client)
  end

  context 'with valid args, options, and env' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'creates a defaults file' do
      expect(git_client).to receive(:branch_exists?).
        with('master').
        and_return(true)

      expect(git_client).to receive(:create_defaults).
        with('webapp', { 'params' => { 'port' => 80 }, 'tags' => {} }, 'master').
        and_return([{ 'params' => { 'port' => 80 }, 'tags' => {} }])

      run_command(args: ['webapp'])

      expect(command).to respond_with([
        {
          'params' => { 'port' => 80 },
          'tags' => {}
        }
      ])
    end
  end

  context 'with invalid git env' do
    it 'returns an error if missing git env vars' do
      expect {
        run_command(args: ['webapp'])
      }.to raise_error(Cog::Abort, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
    end
  end

  context 'with invalid args' do
    let(:cog_env) { [{ 'params' => { 'port' => 80 } }] }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'returns an error if missing name' do
      allow(git_client).to receive(:branch_exists?).
        with('master').
        and_return(true)

      expect {
        run_command(args: [])
      }.to raise_error(Cog::Abort, 'Name not provided. Provide a name as the first argument.')
    end

    it 'returns an error if invalid name is passed' do
      expect {
        run_command(args: ['! # l #'])
      }.to raise_error(Cog::Abort, 'Name must only include word characters [a-zA-Z0-9_-].')
    end
  end

  context 'with invalid options' do
    let(:cog_env) { [{ 'params' => { 'port' => 80 } }] }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'returns an error if the provided branch does not exist' do
      expect(git_client).to receive(:branch_exists?).
        with('dev').
        and_return(false)

      expect {
        run_command(args: ['webapp'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Branch dev does not exist. Create a branch, push it to your repository\'s origin, and try again.')
    end
  end

  context 'with env that has more than one item' do
    let(:cog_env) { [{ 'params' => { 'port' => 80 } }, { 'params' => { 'port' => 8080 } }] }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'returns an error if there is more than one item passed in previous input' do
      expect {
        run_command(args: ['webapp'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Input from previous command must only include a single item.')
    end
  end

  context 'with env that does not have the right structure' do
    let(:cog_env) { [{ 'port' => 80 }] }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'returns an error if the json structure does not have the right keys' do
      expect {
        run_command(args: ['webapp'])
      }.to raise_error(Cog::Abort, 'Defaults must include at least a "params" or "tags" key.')
    end
  end
end
