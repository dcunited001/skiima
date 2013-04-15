require "skiima"

namespace :skiima do

  desc "Runs Skiima.up for :default group in dependencies.yml"
  task :up, [:skiima_env, :group] do
    args.with_defaults(:skiima_env => 'development', :group => 'default')
    Skiima.up(args.skiima_env.to_sym, args.group.to_sym)
  end

  desc "Runs Skiima.down for :default group in dependencies.yml"
  task :down, [:skiima_env, :group] do
    args.with_defaults(:skiima_env => 'development', :group => 'default')
    Skiima.down(args.skiima_env.to_sym, args.group.to_sym)
  end

  namespace :test, [:skiima_env, :group] do
    desc "Runs Skiima.up for :test group in dependencies.yml"
    task :up do
      args.with_defaults(:skiima_env => 'test', :group => 'test')
      Skiima.up(args.skiima_env.to_sym, args.group.to_sym)
    end

    desc "Runs Skiima.down for :test group in dependencies.yml"
    task :test, [:skiima_env, :group] do
      args.with_defaults(:skiima_env => 'test', :group => 'test')
      Skiima.down(args.skiima_env.to_sym, args.group.to_sym)
    end
  end

end
