class RemoteHandler < Lokii::Handler
  def process
    Lokii::Logger.debug "Processing message with the remote handler"
    # TODO, would be nice to know which number was the receiver
    Inbox.create(
      :number => message[:number], 
      :text => message[:text], 
      :sent_at => message[:created_at],
      :processed_at => message[:processed_at] )
  rescue Exception => e
    # For now we are not going to do anything special with errors, maybe we will          
    Lokii::Logger.debug 'Error sending to remote server: ' + e.message  
  end
end