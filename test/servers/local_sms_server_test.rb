require File.join(File.dirname(__FILE__), '..', 'test_helper')

class LocalSmsServerTest < Test::Unit::TestCase
  context "message received" do
    setup do
      @server = Lokii::LocalSmsServer.new
      Lokii::Config.valid_numbers = [Lokii::Config.valid_numbers] unless Lokii::Config.valid_numbers.is_a? Array
      Lokii::Config.valid_numbers = Lokii::Config.valid_numbers.map{|v| Regexp.new(v)}      
    end
    
    should "reject invalid numbers" do
      number = "+5691234567"
      number = @server.format_number(number)
      should_raise InvalidPhoneNumberError do
        @server.validate_number number
      end      
    end
    
    should "accept correctly formatted numbers" do
      number = "+56912345678"
      number = @server.format_number(number)
      @server.validate_number number
    end
    
    should "clean incorrect characters" do
      number = " +569 12 34 5678 "
      number = @server.format_number(number)
      @server.validate_number number
    end
  end  
end