class Outbox < ResourceParty::Base
  base_uri Lokii::Config.remote
  default_params :api_key => Lokii::Config.api_key
  route_for 'outbox'
  resource_for 'outbox'
end