ENV['LOKII_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'factory_girl'

require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
require 'lokii/test'

# Because we are dealing with remotes, we deal with some fakery
require 'fake_web'
FakeWeb.allow_net_connect = false

Dir[File.join(Lokii::Config.root, 'test', 'factories', '**', '*.rb')].each {|f|
  require f 
}

class Test::Unit::TestCase

  def should_raise(*args, &block)
    opts = args.first.is_a?(Hash) ? args.fist : {}
    opts[:kind_of] = args.first if args.first.is_a?(Class)
    yield block
    flunk opts[:message] || "should raise an exception, but none raised"
  rescue Exception => e
    assert e.kind_of?(opts[:kind_of]), opts[:message] || "should raise exception of type #{opts[:kind_of]}, but got #{e.class} instead" if opts[:kind_of]
  end
    
end