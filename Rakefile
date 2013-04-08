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

namespace :db do
  namespace :test do
    namespace :prepare do

      task :postgresql do
        Skiima.setup do |config|
          config.root_path = SPEC_ROOT
          config.config_path = 'config'
          config.scripts_path = 'db/skiima'
          config.locale = :en
        end

        env = :postgresql_root
        test_env = :postgresql_test
        db = Skiima.read_db_yml(Skiima.full_database_path)
        vars = { database: db[test_env]['database'], testuser: 'skiima', testpass: 'test'}

        Skiima.up(env, :init_test_db, vars: vars)
      end

      task :mysql do
        Skiima.setup do |config|
          config.root_path = SPEC_ROOT
          config.config_path = 'config'
          config.scripts_path = 'db/skiima'
          config.locale = :en
        end

        env = :mysql_root
        test_env = :mysql_test
        db = Skiima.read_db_yml(Skiima.full_database_path)
        vars = { database: db[test_env]['database'], testuser: 'skiima', testpass: 'test'}

        Skiima.up(env, :init_test_db, vars: vars)
      end

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
