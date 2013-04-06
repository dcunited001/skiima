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
        db = Skiima.read_db_yml(Skiima.full_database_path)
        database = db[:postgresql_test]['database']
        vars = { testuser: 'skiima', testpass: 'test'}

        # can't be executed in multiline statement?
        #   break up into multiple sql statements?
        # Skiima.up(env, :init_test_db, vars: vars)

        ski = Skiima.new(env, vars: vars)
        ski.connection.execute("DROP DATABASE IF EXISTS #{database};")
        ski.connection.execute("DROP ROLE IF EXISTS #{vars[:testuser]};")
        ski.connection.execute("CREATE DATABASE #{database};")
        ski.connection.execute("CREATE ROLE #{vars[:testuser]} WITH PASSWORD '#{vars[:testpass]}' LOGIN;")
        ski.connection.execute("GRANT ALL PRIVILEGES ON DATABASE #{database} TO #{vars[:testuser]};")
      end

      task :mysql do
        Skiima.setup do |config|
          config.root_path = SPEC_ROOT
          config.config_path = 'config'
          config.scripts_path = 'db/skiima'
          config.locale = :en
        end

        env = :mysql_root
        db = Skiima.read_db_yml(Skiima.full_database_path)
        database = db[:mysql_test]['database']
        vars = { testuser: 'skiima', testpass: 'test'}

        ski = Skiima.new(env, vars: vars)
        ski.connection.execute("DROP DATABASE IF EXISTS #{database};")
        ski.connection.execute("DROP USER '#{vars[:testuser]}'@'localhost';")
        ski.connection.execute("CREATE DATABASE #{database};")
        ski.connection.execute("CREATE USER '#{vars[:testuser]}'@'localhost' IDENTIFIED BY '#{vars[:testpass]}';")
        ski.connection.execute("GRANT ALL PRIVILEGES ON #{database}.* TO '#{vars[:testuser]}'@'localhost';")
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
