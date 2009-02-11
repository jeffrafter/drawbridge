class RemoteServer < Lokii::Server  
  attr_accessor :since
  
  def initialize
    # Need to actually store this...
    @since = 1.hour.ago
  end
  
  def check
    responses = Message.all(:since => self.since)
    responses.each do |response|
      say response.message, response.number
      sent = response.updated_at || response.created_at
      self.since = sent if sent > self.since
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
end