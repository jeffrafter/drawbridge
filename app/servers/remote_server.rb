require 'time'
require 'yaml'

class RemoteServer < Lokii::Server  
  def since
    @since ||= YAML.load_file(history) rescue nil
    @since ||= Time.now
    @since
  end
  
  def since=(value)
    @since = value
    File.open(history, 'w') {|out| YAML.dump(@since, out) }
  end
  
  def check
    messages = Outbox.all(:since => self.since.iso8601)
    messages.each do |message|
      say message.text, message.number
      self.since = message.updated_at.utc if message.updated_at.utc > self.since
    end
  rescue Exception => e
    Lokii::Logger.debug 'Error connecting to remote server: ' + e.message  
  end

  def say(text, number, reply = nil)
    Lokii::Logger.debug "Sending message to #{number}:"
    Lokii::Logger.debug "#{text}"
    Lokii::Logger.debug ""
    Lokii::Processor.servers.first.say(text, number, reply)
  end
  
  def receive(text, number, sent)
    # We don't want to receive anything from the users in here!
  end  
  
  def handle(message)
    # We don't want to handle anything from the users in here!    
  end

private
  def history
    File.join(Lokii::Config.root, 'config', 'history.yml')  
  end
end