require 'cog'
require 'rspec/cog'

module FixtureHelper
  def fixture(path)
    File.new(File.join('spec/fixtures', path), 'r')
  end
end

RSpec.configure do |config|
  config.include Cog::RSpec::Setup
  config.include FixtureHelper
end
