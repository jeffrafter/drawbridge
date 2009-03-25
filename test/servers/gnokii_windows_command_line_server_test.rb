require File.join(File.dirname(__FILE__), '..', 'test_helper')

class GnokiiWindowsCommandLineServerTest < Test::Unit::TestCase
  context "message received" do
    setup do
      @server = Lokii::GnokiiWindowsCommandLineServer.new
      File.open(File.join(Lokii::Config.root, 'tmp/incoming').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR), 'w') do |file|
        file.puts "1. Inbox Message (Read)"
        file.puts "Date/time: 24/03/2009 17:23:12 -1900" 
        file.puts "Sender: +16507991415 Msg Center: +12063130004" 
        file.puts "Text:" 
        file.puts "Hello World"     
      end  
    end
    
    should "be parseable" do
      message = @server.send(:parsesms)
      assert_equal Time.parse("2009-03-24T17:23:12-19:00"), message[:created_at]
      assert_equal "+16507991415", message[:number]
      assert_equal "Hello World", message[:text]
      assert_equal 1, message[:phone]
    end
  end  
end