# encoding: utf-8
require 'rubygems'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'skiima'

SPEC_ROOT = File.join(File.dirname(__FILE__), 'spec')


Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => :test

namespace :test do
  namespace :prepare do

    task :postgresql do
      Skiima.setup do |config|
        config.root_path = SPEC_ROOT
        config.config_path = 'config'
        config.scripts_path = 'db/skiima'
        config.locale = :en
      end

      db_config = Skiima.read_db_yaml(Skiima.full_database_path)[:development]
      Skiima.new(:development)
      Skiima.read_sql_file('init_test_db', 'database.skiima_test.postgresql.current.sql')
    end

    task :mysql do
      Skiima.setup do |config|
        config.root_path = SPEC_ROOT
        config.config_path = 'config'
        config.scripts_path = 'db/skiima'
        config.locale = :en
      end

      db_config = Skiima.read_db_yaml(Skiima.full_database_path)
      Skiima.read_sql_file('init_test_db', 'database.skiima_test.mysql.current.sql')
    end

  end
end

#desc 'Generate documentation for Skiima.'
#Rake::RDocTask.new(:rdoc) do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title    = 'Skiima'
#  rdoc.options << '--line-numbers' << '--inline-source'
#  rdoc.rdoc_files.include('README.rdoc')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
