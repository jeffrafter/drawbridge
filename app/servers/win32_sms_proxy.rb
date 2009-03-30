require 'win32/sms'
require 'date'
require 'time'
require 'lucky_sneaks/unidecoder'

module Lokii

  class Win32SmsProxy
    attr_reader :modem

    def initialize(modem)
      @modem = modem
    end

    def sms(number, text)
      text = LuckySneaks::Unidecoder::decode(text)
      @modem.sms(number, text)
    end
    
    def messages
      @modem.process
      @modem.messages || []
    end
  end  
end