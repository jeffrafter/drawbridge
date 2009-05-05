
class InvalidPhoneNumberError < RuntimeError; end

module Lokii

  # The sms server operates against connected sms modem(s). If the ports 
  # property is specified in the settings it will try to pool connections 
  # to the various ports, otherwise it will attempt to auto-detect
  class ClickatellSmsServer < Server
  
    attr_reader :proxies

    def connect
      Lokii::Logger.debug "Connecting"
      Lokii::Config.valid_numbers = [Lokii::Config.valid_numbers] unless Lokii::Config.valid_numbers.is_a? Array
      Lokii::Config.valid_numbers = Lokii::Config.valid_numbers.map{|v| Regexp.new(v)}      
   end      
  
    def check
    end

    def say(text, number, reply = nil)
      number = format_number(number)
      validate_number(number)
      number.gsub!(/^\+/, '')
      msg = encode(text, 'ascii')
      msg = msg[0..160]
      c = ClickatellSimple.new('3166189', Lokii::Config.clickatell_user, Lokii::Config.clickatell_password)
      c.sms(msg, number, '56994110587')      
    rescue InvalidPhoneNumberError => e
      Lokii::Logger.debug "Could not send message because the number is not valid #{e.message}"  
    rescue Exception => e
      Lokii::Logger.debug "Could not send message #{e.message}"  
    end

    def format_number(number)
      re = Regexp.new(Lokii::Config.format_numbers)
      number = number.gsub(re, '')
      number = "569#{number}" if number =~ /^\d{8}$/
      number
    end

    def validate_number(number)    
      Lokii::Config.valid_numbers.each {|validator|
        return number if validator.match(number)
      }  
      raise InvalidPhoneNumberError.new("Invalid number format '#{number}'")
    end  
        
  end      
    
  def encode(msg, encoding)
    @encoding = encoding.to_sym rescue nil
    if (@encoding == :ascii)
      require 'lucky_sneaks/unidecoder'
      msg = LuckySneaks::Unidecoder::decode(msg)
      msg
    elsif (@encoding == :utf8)
      # Unpacking and repacking supposedly cleans out bad (non-UTF-8) stuff
      utf8 = msg.unpack("U*")
      packed = utf8.pack("U*")
      packed
    elsif (@encoding == :ucs2)
      ucs2 = Iconv.iconv("UCS-2", "UTF-8", msg).first
      ucs2 = ucs2.unpack("H*").join
      ucs2
    else
      msg
    end
  end
end