class AuthHandler < Lokii::Handler
  def process
    Lokii::Logger.debug "Processing message with the auth handler"
    authenticate message[:number]
  end
  
private 
  
  def authenticate(number)
    if authenticate_from_cache(number) || authenticate_remote(number)
      Cache.store(:user, number, @user.attributes)
    else
      params = {:number => number, :command => :invite, :message => number}
      Command.perform(params)
      halt
    end
  end
  
  def authenticate_from_cache(number)
    @user = Cache.user(:number => number)    
    !@user.blank?
  end
  
  def authenticate_remote(number)
    @user = Session.verify(number)
  rescue 
    halt
  end
  
end