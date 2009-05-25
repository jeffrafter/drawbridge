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
      save message
      self.since = message.updated_at.utc if message.updated_at.utc > self.since
    end
    send
  rescue Exception => e
    Lokii::Logger.debug 'Error trying to retrieve and send message: ' + e.message + "\n" + e.backtrace.join("\n  ")
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
  
  # Save this message to the local store for queueing 
  def save(message)
    filename = Lokii::Config.store + ("%02d" % message.priority.to_i) + '_' + Time.now.iso8601 + '.yml'
    filename = File.expand_path(filename)
    File.open(filename, 'w') {|out| out.write message.to_yaml }
  end
  
  # Loads the next message in priority
  def send
    files = Dir[Lokii::Config.store.gsub(/\\/, '/') + "*"]
    filename = files.first
    filename = File.expand_path(filename)
    return unless filename
    message = YAML.load_file(filename)
    return unless message
    say message.text, message.number     
    File.rm(filename)
  end
end