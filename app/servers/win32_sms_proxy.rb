require 'win32/sms'
require 'date'
require 'time'

module Lokii

  class Win32SmsProxy
    attr_reader :modem

    def initialize(modem)
      @modem = modem
    end

    def sms(number, text)
      @modem.sms(number, text)
    end
    
    def messages
      @modem.process
    end
  end  
end