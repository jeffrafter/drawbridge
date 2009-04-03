namespace :phone do
  desc "Check the balance"  
  task :balance do  
    require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
    Lokii::Processor.servers.first.connect
    Lokii::Processor.servers.first.balance?
  end  
end
