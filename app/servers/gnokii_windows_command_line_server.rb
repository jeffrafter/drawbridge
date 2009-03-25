module Lokii
  class GnokiiWindowsCommandLineServer < Server

    class ReadError < RuntimeError; end
    class WriteError < RuntimeError; end
  
    attr_reader :proxies, :mailbox

    def connect
      Lokii::Logger.debug "Connecting"
    end      
  
    def check
      loop do
        getsms
        parsesms      
      end  
    rescue ReadError
      # Do nothing
    end

    def say(text, number, reply = nil)
      File.open(outgoing, 'w') do |file|
        file.puts text + "\r\n"
      end
      `#{gnokii} --config #{config} --sendsms #{number} < #{outgoing}`  
      raise WriteError unless $?.exitstatus == 0
    end
    
  private
    def join(*args)
      file = File.join(*args)
      file.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    end
  
    def gnokii
      join(Lokii::Config.root, 'bin/gnokii')
    end
    
    def incoming
      join(Lokii::Config.root, 'tmp/incoming')
    end
  
    def outgoing
      join(Lokii::Config.root, 'tmp/outgoing')
    end
    
    def config
      join(Lokii::Config.root, 'config/gnokiirc')
    end
  
    def getsms
      `#{gnokii} --config '#{config}' --getsms #{@mailbox || 'MT'} 1 -F '#{incoming}'`
      raise ReadError unless $?.exitstatus == 0
    end
    
    # Expecting a file with the format
    #
    #   1. Inbox Message (Read)
    #   Date/time: 24/03/2009 17:23:12 -1900
    #   Sender: +16507991415 Msg Center: +12063130004
    #   Text:
    #   Hello World
    #
    def parsesms
      header = nil
      date_time = nil      
      sender = nil
      field = nil
      text = nil
      File.open(incoming, 'r') do |file|
        header = file.readline
        date_time = file.readline
        sender = file.readline
        field = file.readline
        text = file.gets(nil)
      end      
      sender = sender.match(/^Sender:\s+([^\s]+)/).captures[0]
      date_time = date_time.match(/^Date\/time:\s+(.+)/).captures[0]
      date_time = DateTime.strptime(date_time, "%d/%m/%Y %H:%M:%S %z")      
      {:phone => 1,
       :number => sender,
       :text => text.strip,
       :created_at => date_time,
       :processed_at => Time.now}
    end    
  end  
end