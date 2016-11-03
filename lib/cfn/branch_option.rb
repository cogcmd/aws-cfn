require 'cfn/command'

module Cfn::BranchOption
  def self.included(klass)
    unless [:git_client, :request].all? { |m| klass.instance_methods.include?(m) }
      fail "#{self.name} can only be inlcuded into classes that provide git_client and request instance methods."
    end
  end

  def require_branch_exists!
    unless git_client.branch_exists?(branch)
      raise(Cog::Error, "Branch #{branch} does not exist. Create a branch and push it to your repository's origin and try again.")
    end
  end

  def branch
    request.options['branch'] || 'master'
  end
end
