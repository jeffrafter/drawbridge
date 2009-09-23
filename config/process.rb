Lokii::Processor.servers.each{|server| server.connect }

 loop do
   Lokii::Processor.process
   sleep(Lokii::Config.interval)  
 end

Lokii::Processor.servers.each{|server| server.disconnect }