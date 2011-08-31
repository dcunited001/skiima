

namespace :skiima do
  desc "migrates database, then runs all skiima migrations"
  task :migrate => [:environment, 'db:migrate'] do

  end

  desc "loads schema, then runs all skiima migrations"
  task :migrate => [:environment, 'db:schema:load'] do

  end

  desc "drops all skiima objects"
  task :drop => :environment do

  end
end
