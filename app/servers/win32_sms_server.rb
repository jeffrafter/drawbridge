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
      @proxies = modems.map{|modem| Lokii::Win32SmsProxy.new(modem) }
      @current = 0
    end      
  
    def check
      self.proxies.each {|proxy|
        proxy.messages.each {|message|
          handle(message)    
        }      
      }  
    end

    def say(text, number, reply = nil)
      @current += 1
      @current = 0 if @current > proxies.size - 1 
      @proxies[@current].outgoing(number, text)
    end
  end  
end