require 'spec_helper'

require 'cog_cmd/cfn/template/show'
require 'cfn/git_client'

describe CogCmd::Cfn::Template::Show do
  let(:command_name) { 'template-show' }
  let(:git_client) { double(Cfn::GitClient) }

  before do
    allow(Cfn::GitClient).to receive(:new).and_return(git_client)
  end

  context 'with valid args, options, and env' do
    let(:template_body) { fixture('template.yaml').read }
    let(:template) { YAML.load(template_body) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GIT_REMOTE_URL').and_return('github.com:operable/cfn-test-repo.git')
      allow(ENV).to receive(:[]).with('GIT_SSH_KEY').and_return('not-actually-a-private-key')
    end

    it 'shows an existing template' do
      expect(git_client).to receive(:ref_exists?).
        with({ branch: 'master' }).
        and_return(true)

      expect(git_client).to receive(:template_exists?).
        with('ec2', branch: 'master').
        and_return(true)

      expect(git_client).to receive(:show_template).
        with('ec2', branch: 'master').
        and_return({ name: 'ec2', body: template_body, data: template })

      run_command(args: ['ec2'])

      expect(command).to respond_with([{ name: 'ec2', body: template_body, data: template }])
    end
  end

  context 'with invalid git env' do
    it 'returns an error if missing git env vars' do
      expect {
        run_command(args: ['ec2'])
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
        run_command(args: ['ec2'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Branch dev does not exist. Create a branch, push it to your repository\'s origin, and try again.')
    end

    it 'returns an error if the template does not exist' do
      expect(git_client).to receive(:ref_exists?).
        with(branch: 'dev').
        and_return(true)

      expect(git_client).to receive(:template_exists?).
        with('doesnt-exist', branch: 'dev').
        and_return(false)

      expect {
        run_command(args: ['doesnt-exist'], options: { 'branch' => 'dev' })
      }.to raise_error(Cog::Abort, 'Template does not exist. Check that the template exists in the dev branch and has been pushed to your repository\'s origin.')
    end
  end
end
