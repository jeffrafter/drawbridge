namespace :logs do
  desc "Rotate the logs up to the server"  
  task :rotate do  
    require File.join(File.dirname(__FILE__), '..', 'config', 'boot')
    filename = File.join(Lokii::Config.root, 'log', 'development.log').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
    puts "Reading log file"
    log = IO.read(filename)
    puts "Uploading"
    Log.create(:text => log)
    puts "Deleting existing log"
    File.delete('"' + filename + '"')
    puts "Done"
  end  
end
