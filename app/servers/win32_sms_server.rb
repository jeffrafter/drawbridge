module Lokii

  # The sms server operates against connected sms modem(s). If the ports 
  # property is specified in the settings it will try to pool connections 
  # to the various ports, otherwise it will attempt to auto-detect
  class Win32SmsServer < Server
  
    attr_reader :proxies

    def connect
      Lokii::Logger.debug "Connecting"
      modems = []
      ports = Lokii::Config.ports.split(',') rescue []
      ports.each {|port| modems << Win32::Sms.new(port) }
      modems = [Win32::Sms.new] if modems.empty?
      modems.each {|modem| modem.encoding = Lokii::Config.encoding.to_sym} if Lokii::Config.encoding
      modems.each {|modem| modem.ignore_unknown_errors = true} if Lokii::Config.ignore_unknown_errors == 'y'
      @proxies = modems.map{|modem| Lokii::Win32SmsProxy.new(modem) }
      @current = 0
    end      
  
    def check
      self.proxies.each {|proxy|
        proxy.messages.each {|message|
          message = {:phone => 0,
                     :number => message[:from],
                     :text => message[:text],
                     :created_at => message[:created_at],
                     :processed_at => message[:processed_at]}
          handle(message)    
        }      
      }  
    end

    def say(text, number, reply = nil)
      number = format_number(number)
      @current += 1
      @current = 0 if @current > proxies.size - 1 
      @proxies[@current].sms(number, text)
    rescue
      puts "Could not send message because the number is not valid"  
    end
    
    def country_code
      56
    end
    
    def format_number(number)
      re = /\+#{country_code}\d{9}/
      number = clean_number(number)      
      raise InvalidPhoneNumberError.new("Invalid number format #{number}") unless re.match(number)
      number
    end
    
    def clean_number(number)
      number = number.gsub(/[^0-9]/, '')
      number = number.gsub(/^#{country_code}/, '')
      number = number.gsub(/^0/, '')
      "+#{country_code}#{number}"
    end
  end      
end