class Message < ResourceParty::Base
  base_uri Lokii::Config.remote
  route_for 'messages'
  resource_for 'message'
end