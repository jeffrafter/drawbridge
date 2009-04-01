namespace :logs do
  desc "Rotate the logs up to the server"  
  task :rotate do  
    require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
    filename = File.join(Lokii::Config.root, 'log', 'development.log').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    log = IO.read(filename)
    Log.create(:log => log)
    File.delete(filename)
  end  
end
