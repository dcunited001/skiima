require 'bundler/gem_tasks'
require 'rdoc/task'

desc 'Generate documentation for Skiima.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Skiima'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new do |i|
  i.test_files = FileList['test/**/test_*.rb']
  i.verbose = true
end