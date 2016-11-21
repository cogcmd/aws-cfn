require 'yaml'

# Make sure we're running from the directory the Rakefile lives in since
# many things (ie: docker build, config reading) use relative paths.
Dir.chdir(File.dirname(__FILE__))

BUNDLE_CONFIG = YAML.load(File.read('config.yaml'))
BUNDLE_VERSION = BUNDLE_CONFIG['version']
BUNDLE_IMAGE = "#{BUNDLE_CONFIG['docker']['image']}:#{BUNDLE_CONFIG['docker']['tag']}"

task :image do |t|
  sh 'docker', 'build', '-t', BUNDLE_IMAGE, '.'
end

task push: [:image] do |t|
  sh 'docker', 'push', BUNDLE_IMAGE
end

task release: [:push] do |t|
	sh 'git', 'tag', BUNDLE_VERSION
	sh 'git', 'push', 'origin', BUNDLE_VERSION
end

task :readme do |t|
  name             = BUNDLE_CONFIG['name']
  description      = BUNDLE_CONFIG['description']
  version          = BUNDLE_CONFIG['version']
  long_description = BUNDLE_CONFIG['long_description']
  config_notes     = BUNDLE_CONFIG['config']['notes']
  env              = BUNDLE_CONFIG['config']['env'].map { |e| "* `#{e['var']}`\n  > #{e['description']}" }.join("\n\n")
  commands         = BUNDLE_CONFIG['commands'].map { |name, c| "* `#{name}`\n  > #{c['description']}" }.join("\n\n")

  readme = <<~END
  # #{name} - #{description} (#{version})

  #{long_description}

  ## Installation

  In chat:

  ```
  @cog bundle install cfn
  ```

  Via cogctl:

  ```
  cogctl bundle install cfn
  ```

  For more details about how to install and configure bundles see:

  * [Installing Bundles](https://cog-book.operable.io/#_installing_bundles)
  * [Dynamic Command Configuration](https://cog-book.operable.io/#_dynamic_command_configuration)
  
  ## Commands

  The following commands are included with the bundle. For usage info
  about each command see the `help` builtin command: `help #{name}:<command_name>`.

  #{commands}

  ## Configuration

  #{config_notes}
  
  #{env}
  END

  File.write('README.md', readme)
end
