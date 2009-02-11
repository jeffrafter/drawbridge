class CommandHandler < Lokii::Handler
  def process
    Lokii::Logger.debug "Processing message with the command handler"
    args = message[:text].split(/\s/)
    cmd = args.shift rescue nil
    params = {:number => message[:number], :command => cmd, :message => args.join(' ')}
    Command.perform(params)
  end
end