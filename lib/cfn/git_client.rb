require 'rugged'
require 'json'
require 'yaml'
require 'pathname'
require 'tmpdir'
require 'tempfile'

module Cfn
  class GitClient
    attr_reader :credential_file, :credential, :repository

    def initialize(remote_url, ssh_key_contents)
      @credential_file = Tempfile.new('cfn-ssh-key')
      @credential = create_credential(@credential_file, ssh_key_contents)
      @repository = clone_repository(remote_url, @credential)
    end

    def create_defaults(name, body, branch = 'master')
      path = "defaults/#{name}.json"

      reset_hard_branch(branch)
      create_file(path, JSON.pretty_generate(body))
      create_commit([path], "Create Defaults: #{name}")
      push_repository(branch)

      [{ name: name, body: body }]
    end

    def list_defaults(filter = '*', ref = { branch: 'master' })
      reset_hard_ref(ref)
      path_with_glob = workdir_path("defaults/#{filter}")
      files = Dir.glob(path_with_glob)
      files.map { |p| { name: File.basename(p, '.json') } }
    end

    def show_defaults(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path("defaults/#{name}.json")
      body = File.read(absolute_path)
      { name: name, data: JSON.parse(body) }
    end

    def list_templates(filter = '**/*', ref = { branch: 'master' })
      reset_hard_ref(ref)
      path_with_glob = workdir_path("templates/#{filter}")
      base_path = Pathname.new(workdir_path("templates/"))
      files = Dir.glob(path_with_glob).map { |p| Pathname.new(p) }
      template_files = files.select { |path| ['.yml', '.yaml', '.json'].include?(path.extname.downcase) }

      template_files.map do |path|
        folder = path.relative_path_from(base_path).dirname
        name = path.basename(path.extname)
        { name: folder.join(name) }
      end
    end

    def show_template(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path("templates/#{name}.{json,yml,yaml}")
      entries = Dir.glob(absolute_path)
      body = File.read(entries.first)
      data = YAML.load(body)
      { name: name, body: body, data: data }
    end

    def create_definition(name, definition, template, timestamp, branch = 'master')
      path = "definitions/#{name}/#{timestamp}"
      template_path = "#{path}/template.yaml"
      definition_path = "#{path}/definition.yaml"

      reset_hard_branch(branch)
      create_file(template_path, template)
      create_file(definition_path, definition.to_yaml)
      create_commit([template_path, definition_path], "Definition Create: #{name}")
      push_repository(branch)

      definition
    end

    def list_definitions(filter = '*', ref = { branch: 'master' })
      reset_hard_ref(ref)
      path_with_glob = workdir_path("definitions/#{filter}")
      dirs = Dir.glob(path_with_glob)

      dirs.map { |path| read_definition(File.basename(path)) }
    end

    def show_definition(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      read_definition(name)
    end

    def read_definition(name)
      absolute_path = workdir_path("definitions/#{name}/*/definition.yaml")
      path = Dir.glob(absolute_path).sort.last
      body = File.read(path)
      data = YAML.load(body)

      # Decorate the definition object with the timestamp of the
      # Git directory it lives in.
      data['timestamp'] = File.split(File.dirname(path))[1]

      { name: name, body: body, data: data }
    end

    def branch_sha(branch)
      repository.branches["origin/#{branch}"].target_id
    end

    def defaults_exists?(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path("defaults/#{name}.json")
      File.exist?(absolute_path)
    end

    def template_exists?(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path("templates/#{name}.{json,yml,yaml}")
      entries = Dir.glob(absolute_path)
      entries.any? { |e| File.exist?(e) }
    end

    def definition_exists?(name, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path("definitions/#{name}/*/definition.yaml")
      entries = Dir.glob(absolute_path)
      entries.any? { |e| File.exist?(e) }
    end

    def file_exists?(path, ref = { branch: 'master' })
      reset_hard_ref(ref)
      absolute_path = workdir_path(path)
      entries = Dir.glob(absolute_path)
      entries.any? { |e| File.exist?(e) }
    end

    def ref_exists?(ref)
      if branch = ref[:branch]
        branch_exists?(branch)
      elsif tag = ref[:tag]
        tag_exists?(tag)
      elsif sha = ref[:sha]
        sha_exists?(sha)
      end
    end

    def branch_exists?(branch)
      repository.branches.exists?("origin/#{branch}")
    end

    def tag_exists?(tag)
      !!repository.tags[tag]
    end

    def sha_exists?(sha)
      commit = repository.rev_parse(sha)
      commit.is_a?(Rugged::Commit)
    rescue Rugged::ReferenceError
      false
    end

    private

    def create_credential(file, ssh_key_contents)
      file.write(ssh_key_contents)
      file.close

      Rugged::Credentials::SshKey.new(
        username: 'git',
        privatekey: file.path
      )
    end

    def clone_repository(remote_url, credential)
      Rugged::Repository.clone_at(
        remote_url,
        Dir.mktmpdir,
        credentials: credential
      )
    end

    def fetch_origin
      origin = repository.remotes['origin']
      origin.fetch(nil, credentials: credential)
    end

    def reset_hard_ref(ref)
      if branch = ref[:branch]
        reset_hard_branch(branch)
      elsif tag = ref[:tag]
        reset_hard_tag(tag)
      elsif sha = ref[:sha]
        reset_hard_sha(sha)
      end
    end

    def reset_hard_branch(branch)
      branch = repository.branches["origin/#{branch}"]
      repository.reset(branch.target, :hard)
    end

    def reset_hard_tag(tag)
      tag = repository.tags[tag]
      repository.reset(tag.target, :hard)
    end

    def reset_hard_sha(sha)
      commit = repository.rev_parse(sha)
      repository.reset(commit, :hard)
    end

    def create_file(path, body)
      absolute_path = workdir_path(path)
      FileUtils.mkdir_p(File.dirname(absolute_path))
      File.write(absolute_path, body)
    end

    def create_commit(paths, message = nil)
      index = repository.index
      parent = repository.head.target
      message = "Cog commit: #{paths}" if message.nil?

      paths.each do |path|
        oid = Rugged::Blob.from_workdir(repository, path)
        index.add(path: path, oid: oid, mode: 0100644)
      end

      commit_tree = index.write_tree(repository)
      index.write

      author = {
        email: 'cog@operable.io',
        name: "Cog: #{ENV['COG_CHAT_HANDLE']}",
        time: Time.now
      }

      Rugged::Commit.create(
        repository,
        author: author,
        committer: author,
        message: commit_message(message, paths),
        parents: [parent],
        tree: commit_tree,
        update_ref: 'HEAD'
      )
    end

    def commit_message(message, paths)
      message += "\n\n" + <<~EOF
        Created Files:
        #{ paths.map { |p| "- #{p}" }.join("\n") }

        Creator Chat Handle:
        #{ ENV["COG_CHAT_HANDLE"]}
      EOF
    end

    def push_repository(branch = 'master')
      remote = repository.remotes['origin']
      remote.push(["HEAD:refs/heads/#{branch}"], credentials: credential)
    end

    def workdir_path(path)
      workdir = repository.workdir
      File.join(workdir, path)
    end
  end
end
