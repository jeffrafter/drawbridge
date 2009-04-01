class Log < ResourceParty::Base
  base_uri Lokii::Config.remote
  default_params :api_key => Lokii::Config.api_key
  route_for 'log'
  resource_for 'log'
end