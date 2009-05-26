
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
      return unless Lokii::Config.send_using.downcase.to_sym == :clickatell
      number = format_number(number)
      validate_number(number)
      number.gsub!(/^\+/, '')
      msg = encode(text, Lokii::Config.encoding)
      c = ClickatellSimple.new(Lokii::Config.clickatell_api_key, Lokii::Config.clickatell_user, Lokii::Config.clickatell_password)
      c.sms(msg, number, Lokii::Config.forge_sender, Lokii::Config.max_sms_per_message)      
    rescue InvalidPhoneNumberError => e
      Lokii::Logger.debug "Could not send message because the number is not valid #{e.message}"  
    rescue Exception => e
      Lokii::Logger.debug "Could not send message #{e.message}"  
    end

    # Only format numbers that are the default number length
    def format_number(number)
      re = Regexp.new(Lokii::Config.format_numbers)
      number = number.gsub(re, '')
      number = "#{Lokii::Config.country_code}#{Lokii::Config.number_prefix}#{number}" if number =~ /^\d{#{Lokii::Config.number_length}}$/
      number
    end

    def validate_number(number)    
      Lokii::Config.valid_numbers.each {|validator|
        return number if validator.match(number)
      }  
      raise InvalidPhoneNumberError.new("Invalid number format '#{number}'")
    end  
              
    def encode(msg, encoding)
      @encoding = encoding.downcase.to_sym rescue nil
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
end