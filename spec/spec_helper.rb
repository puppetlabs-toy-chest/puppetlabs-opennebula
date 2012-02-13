require 'rspec'
require 'rspec-puppet'
require 'puppet'
require 'mocha'

RSpec.configure do |c|
  c.before :each do
    # See Redmine issue #11191. When using Puppet you can't avoid having a
    # site.pp.
    #
    # This work-around provides a puppetconf area in a fixture directory so the
    # spec tests will run with minimal outside setup.
    Puppet[:confdir] = File.join(File.dirname(__FILE__), "fixtures",
      "puppetconf")
  end

  c.module_path = File.join(File.dirname(__FILE__), "fixtures", "puppetconf",
    "modules")
end
