

namespace :skiima do
  desc "migrates database, then runs all skiima migrations"
  task :migrate => [:environment, 'db:migrate'] do
    rails_db_config = Rails::Configuration.new.database_configuration[Rails.env]

    runner = Skiima::Runner.new(:db_adapter => rails_db_config[:adapter])
    runner.create_sql_objects
  end

  desc "loads schema, then runs all skiima migrations"
  task :migrate => [:environment, 'db:schema:load'] do
    rails_db_config = Rails::Configuration.new.database_configuration[Rails.env]

    runner = Skiima::Runner.new(:db_adapter => rails_db_config[:adapter])
    runner.create_sql_objects
  end

  desc "drops all skiima objects"
  task :drop => :environment do
    rails_db_config = Rails::Configuration.new.database_configuration[Rails.env]

    runner = Skiima::Runner.new(:db_adapter => rails_db_config[:adapter])
    runner.drop_sql_objects
  end
end
