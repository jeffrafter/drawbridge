require File.join(File.dirname(__FILE__), '..', 'test_helper')

class RemoteHandlerTest < Test::Unit::TestCase
  running_server_with_handlers :remote_handler do
    should "not respond" do
      receive 'what do you have to say for yourself?'
      assert responses.blank?
    end
    
    should "forward the message to the remote" do; end
    should "handle remote missing" do; end
    should "handle remote timeouts" do; end
    should "handle remote errors" do; end
  end  
end    
