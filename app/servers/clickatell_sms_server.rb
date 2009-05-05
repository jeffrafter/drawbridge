require 'net/http'
require 'cgi'

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
      command = "https://api.clickatell.com/http/sendmsg?api_id=3166189&user=#{Lokii::Config.clickatell_user}&password=#{Lokii::Config.clickatell_password}&to=#{number}&text=#{CGI::escape(text)}&from=56994110587"
      Lokii::Logger.debug command
      url = URI.parse(command)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }                  
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
end