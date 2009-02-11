class Session < ResourceParty::Base
  base_uri Lokii::Config.remote
  route_for 'session'
  resource_for 'session'
  
  def self.verify(number)
    self.find(:verify, :number => number)
  end
end