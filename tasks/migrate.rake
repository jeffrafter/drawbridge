require 'active_record'  
require 'yaml'  

namespace :db do
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"  
  task :migrate do  
     require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
     ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )  
  end  
end
