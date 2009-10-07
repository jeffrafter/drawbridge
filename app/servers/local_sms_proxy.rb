require 'sms'
require 'date'
require 'time'

module Lokii

  class LocalSmsProxy
    attr_reader :modem

    def initialize(modem)
      @modem = modem
    end

    def sms(number, text)
      begin
        @modem.sms(number, text)
      rescue Exception => e
        Lokii::Logger.warn "ERROR when sending sms: #{e.message} (#{e.class})"
      end
    end
    
    def messages
      begin
        @modem.process
        @modem.messages || []
      rescue Exception => e
        Lokii::Logger.warn "ERROR when fetching messages: #{e.message} (#{e.class})"
      end
    end
  end  
end