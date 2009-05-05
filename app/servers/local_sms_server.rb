class InvalidPhoneNumberError < RuntimeError; end

module Lokii

  # The sms server operates against connected sms modem(s). If the ports 
  # property is specified in the settings it will try to pool connections 
  # to the various ports, otherwise it will attempt to auto-detect
  class LocalSmsServer < Server
  
    attr_reader :proxies

    def connect
      Lokii::Logger.debug "Connecting"
      Lokii::Config.valid_numbers = [Lokii::Config.valid_numbers] unless Lokii::Config.valid_numbers.is_a? Array
      Lokii::Config.valid_numbers = Lokii::Config.valid_numbers.map{|v| Regexp.new(v)}      
      modems = []
      ports = Lokii::Config.ports.split(',') rescue []
      ports.each {|port| modems << Sms.new(port) }
      modems = [Sms.new] if modems.empty?
      modems.each {|modem| modem.encoding = Lokii::Config.encoding.to_sym} if Lokii::Config.encoding
      modems.each {|modem| modem.ignore_unknown_errors = true} if Lokii::Config.ignore_unknown_errors == 'y'
      @proxies = modems.map{|modem| Lokii::LocalSmsProxy.new(modem) }
      @current = 0
    end      
  
    def check
      self.proxies.each {|proxy|
        proxy.messages.each {|message|
          message = {:phone => 0, :number => message[:from], :text => message[:text], :created_at => message[:created_at], :processed_at => message[:processed_at]}
          begin
            message[:number] = format_number(message[:number])
            validate_number(message[:number]) 
          rescue InvalidPhoneNumberError => e
            Lokii::Logger.debug "Skipping message from #{message[:number]} (#{e.message})"
            next
          rescue Exception => e
            Lokii::Logger.debug "Could not receive message from #{message[:number]} (#{e.message})"
            next
          end
          handle(message)    
        }      
      }  
    end

    def say(text, number, reply = nil)
    rescue InvalidPhoneNumberError => e
      Lokii::Logger.debug "Could not send message because the number is not valid #{e.message}"  
    rescue Exception => e
      Lokii::Logger.debug "Could not send message #{e.message}"  
    end

    def format_number(number)
      re = Regexp.new(Lokii::Config.format_numbers)
      number = number.gsub(re, '')
      number = "+569#{number}" if number =~ /^\d{8}$/
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