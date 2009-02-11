require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AuthHandlerTest < Test::Unit::TestCase
  running_server_with_handlers :auth_handler, :i_love_you_handler do
    should "not love unauthenticated users" do
      receive 'i love u', '+987654321'
      assert_response 'You are not authorized to use this service'
      assert_response_to '+987654321'
    end

    should "respond with messages of love if the user is authenticated" do
      receive 'i love u', '+123456789'
      assert_response 'I love you too'
      assert_response_to '+123456789'
    end
  end  
end    
