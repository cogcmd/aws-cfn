require 'cog_cmd/cfn/helpers'
require 'cog_cmd/cfn/template'
require 'cfn/command'
require 'cfn/ref_options'

module CogCmd::Cfn::Template
  class Show < Cfn::Command
    include Cfn::RefOptions
    include CogCmd::Cfn::Helpers

    NAME_FORMAT = /\A[-\w\/]*\z/

    def run_command
      require_git_client!
      require_name!

      template_url =
        if request.options['s3']
          name
        else
          require_name_format!
          require_ref_exists!
          require_template_exists!

          file = git_client.show_template(name, ref)
          s3_client.create_temp_file(file[:body])
        end

      client = Aws::CloudFormation::Client.new

      summary = client.get_template_summary(template_url: template_url).to_h
      summary[:name] = name

      sort_order = {
        :parameters => :parameter_key,
        :tags => :key,
        :outputs => :output_key
      }

      sort_order.each do |type, sort_key|
        next unless summary[type]
        summary[type] = summary[type].sort_by { |p| p[sort_key] }
      end

      response.template = 'template_show'
      response.content = summary
    end

    def require_name!
      unless name
        raise(Cog::Abort, 'Name not provided. Provide a name as the first argument.')
      end
    end

    def require_name_format!
      unless NAME_FORMAT.match(name)
        raise(Cog::Abort, 'Name must only include word characters [a-zA-Z0-9_-/].')
      end
    end

    def require_template_exists!
      unless git_client.template_exists?(name, ref)
        if branch = ref[:branch]
          additional = "Check that the template exists in the #{branch} branch and has been pushed to your repository's origin."
        elsif sha = ref[:tag]
          additional = "Check that the template exists in the #{tag} tag and has been pushed to your repository's origin."
        elsif sha = ref[:sha]
          additional = "Check that the template exists in the git commit SHA #{sha} tag and has been pushed to your repository's origin."
        end

        raise(Cog::Abort, "Template does not exist. #{additional}")
      end
    end

    def name
      request.args[0]
    end
  end
end
