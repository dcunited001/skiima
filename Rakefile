# encoding: utf-8
require 'rubygems'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => :test

#desc 'Generate documentation for Skiima.'
#Rake::RDocTask.new(:rdoc) do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title    = 'Skiima'
#  rdoc.options << '--line-numbers' << '--inline-source'
#  rdoc.rdoc_files.include('README.rdoc')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
