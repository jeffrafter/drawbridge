class Command < ResourceParty::Base
  base_uri Lokii::Config.remote
  route_for 'commands'
  resource_for 'command'
  
  def self.perform(params, query = {})
    response = self.post("/#{self.route}.xml", :body => body_for(params), :query => query, :format => :text)
    raise ResourceParty::ServerError.new(response.body) if response.code != "200"
  end
end