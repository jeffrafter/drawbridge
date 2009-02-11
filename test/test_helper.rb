ENV['LOKII_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'factory_girl'

require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
require 'lokii/test'

# Because we are dealing with remotes, we deal with some fakery
# require 'fakeweb'
# FakeWeb.allow_net_connect = false

factories = Dir[File.join(Lokii::Config.root, 'test', 'factories', '**', '*.rb')]
factories.each {|f| require f }

class Test::Unit::TestCase
#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = false
end