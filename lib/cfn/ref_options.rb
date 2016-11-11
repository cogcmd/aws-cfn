require 'cfn/command'

module Cfn::RefOptions
  def self.included(klass)
    unless [:git_client, :request].all? { |m| klass.instance_methods.include?(m) }
      fail "#{self.name} can only be inlcuded into classes that provide git_client and request instance methods."
    end
  end

  def require_ref_exists!
    unless git_client.ref_exists?(ref)
      if branch = ref[:branch]
        raise(Cog::Abort, "Branch #{branch} does not exist. Create a branch, push it to your repository's origin, and try again.")
      elsif sha = ref[:tag]
        raise(Cog::Abort, "Tag #{tag} does not exist. Create a tag, push it to your repository's origin, and try again.")
      elsif sha = ref[:sha]
        raise(Cog::Abort, "Git commit SHA #{sha} does not exist. Check that the SHA you are referencing has been pushed to your repository's origin and try again.")
      end
    end
  end

  def ref
    if branch
      { branch: branch }
    elsif tag
      { tag: tag }
    elsif sha
      { sha: sha }
    else
      { branch: 'master' }
    end
  end

  def branch
    request.options['branch']
  end

  def tag
    request.options['tag']
  end

  def sha
    request.options['sha']
  end
end
