class User < ResourceParty::Base
  base_uri Lokii::Config.remote
  route_for 'users'
  resource_for 'user'
end