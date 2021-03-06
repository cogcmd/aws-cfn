require 'spec_helper'

require 'cog_cmd/cfn/definition/show'
require 'cfn/git_client'

describe CogCmd::Cfn::Definition::Show do
  let(:command_name) { 'definition-show' }
  let(:git_client) { double(Cfn::GitClient) }

  before do
    allow(Cfn::GitClient).to receive(:new).and_return(git_client)
  end

  context 'with valid args, options, and env' do
    let(:definition_body) { fixture('definition.yaml') }
    let(:definition) { YAML.load(definition_body) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'shows the most recent existing definition' do
      expect(git_client).to receive(:ref_exists?).
        with(branch: 'master').
        and_return(true)

      expect(git_client).to receive(:definition_exists?).
        with('flywheel', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:show_definition).
        with('flywheel', branch: 'master').
        and_return({ name: 'flywheel', body: definition_body, data: definition })

      run_command(args: ['flywheel'])

      expect(command).to respond_with([definition])
    end
  end

  context 'with invalid git env' do
    it 'returns an error if missing git env vars' do
      expect {
        run_command
      }.to raise_error(Cog::Abort, '`GIT_REMOTE_URL` not set. Set the `GIT_REMOTE_URL` environment variable to the ssh or https URL of your git repository.')
    end
  end

  context 'with invalid args' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
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
        run_command(args: ['webapp'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Branch dev does not exist. Create a branch, push it to your repository\'s origin, and try again.')
    end

    it 'returns an error if the definition does not exist' do
      expect(git_client).to receive(:ref_exists?).
        with(branch: 'dev').
        and_return(true)

      expect(git_client).to receive(:definition_exists?).
        with('doesnt-exist', branch: 'dev').
        and_return(false)

      expect {
        run_command(args: ['doesnt-exist'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Definition does not exist. Check that the definition exists in the dev branch and has been pushed to your repository\'s origin.')
    end
  end
end
