# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'skiima'

SPEC_ROOT = File.join(File.dirname(__FILE__), 'spec')

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => :test

namespace :skiima do

  desc "Run Skiima#setup as precursor to rake"
  task :setup do
    Skiima.setup do |config|
      config.root_path = File.join(Skiima.root_path, 'spec')
      config.config_path = 'config'
      config.scripts_path = 'db/skiima'
      config.locale = :en
    end
  end

  namespace :setup do
    namespace :db do

      desc "Setup postgresql test databases to run specs"
      task :postgresql => :'skiima:setup' do
        env = :postgresql_root
        test_env = :postgresql_test
        db = Skiima.read_db_yml(Skiima.full_database_path)
        vars = { database: db[test_env]['database'], testuser: 'skiima', testpass: 'test'}

        Skiima.up(env, :init_test_db, vars: vars)
      end

      desc "Setup postgresql test databases to run specs"
      task :mysql => :'skiima:setup' do
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
