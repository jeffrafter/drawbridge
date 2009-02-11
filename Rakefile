# Add your own tasks in files placed in tasks ending in .rake,
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Test the your application'
Rake::TestTask.new(:test) do |t|
  t.libs << 'config'
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = File.join('test', '**', '*_test.rb')
  t.verbose = true
end
 
desc 'Generate documentation for your application'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Transceivers'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end

Dir[File.join('tasks', '**', '*.rake')].each { |rake| load rake }

# By default, we test. We love tests.
task :default => [:test]
