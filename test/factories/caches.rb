Factory.sequence :cached_user do |n|  
 "<?xml version='1.0' encoding='UTF-8'?>
  <user>
    <id type='integer'>#{n}</id>
    <number>+123456789</number>
  </user>"
end

Factory.define :cache, :class => 'cache' do |cache|
  cache.data         { Factory.next :cached_user }
  cache.name         { :user }
  cache.number       { "+123456789" }
  cache.updated_at   { Time.now }
end