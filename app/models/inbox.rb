class Inbox < ResourceParty::Base
  base_uri Lokii::Config.remote
  default_params :api_key => Lokii::Config.api_key
  route_for 'inbox'
  resource_for 'inbox'
end