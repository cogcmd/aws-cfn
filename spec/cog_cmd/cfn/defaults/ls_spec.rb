require 'spec_helper'

require 'cog_cmd/cfn/defaults/ls'
require 'cfn/git_client'

describe CogCmd::Cfn::Defaults::Ls do
  let(:command_name) { 'defaults-ls' }
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

    it 'lists defaults files' do
      expect(git_client).to receive(:ref_exists?).
        with({ branch: 'master' }).
        and_return(true)

      expect(git_client).to receive(:list_defaults).
        with('*', branch: 'master').
        and_return([{ name: 'webapp', body: '{ "params": { "port": 80 } }', data: { 'params' => { 'port' => 80 } } },
                    { name: 'staging', body: '{ "tags": { "env": "staging" } }', data: { 'tags' => { 'env' => 'staging' } } }])

      run_command

      expect(command).to respond_with([{ name: 'webapp', body: '{ "params": { "port": 80 } }', data: { 'params' => { 'port' => 80 } } },
                                       { name: 'staging', body: '{ "tags": { "env": "staging" } }', data: { 'tags' => { 'env' => 'staging' } } }])
    end

    it 'lists defaults files filtered by a pattern' do
      expect(git_client).to receive(:ref_exists?).
        with({ branch: 'master' }).
        and_return(true)

      expect(git_client).to receive(:list_defaults).
        with('web*', branch: 'master').
        and_return([{ name: 'webapp', body: '{ "params": { "port": 80 } }', data: { 'params' => { 'port' => 80 } } }])

      run_command(args: ['web*'])

      expect(command).to respond_with([{ name: 'webapp', body: '{ "params": { "port": 80 } }', data: { 'params' => { 'port' => 80 } } }])
    end
  end

  context 'with invalid git env' do
    it 'returns an error if missing git env vars' do
      expect {
        run_command
      }.to raise_error(Cog::Abort, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
    end
  end

  context 'with invalid options' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'returns an error if the provided branch does not exist' do
      expect(git_client).to receive(:ref_exists?).
        with(branch: 'dev').
        and_return(false)

      expect {
        run_command(options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Branch dev does not exist. Create a branch, push it to your repository\'s origin, and try again.')
    end
  end
end
