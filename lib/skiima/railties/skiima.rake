namespace :skiima do

  desc "Run Skiima#setup as precursor to rake"
  task :setup do
    Skiima.setup do |config|
      config.config_path = 'config'
      config.scripts_path = 'db/skiima'
      config.locale = :en
    end
  end

  desc "Runs Skiima.up for :default group in dependencies.yml (Run on Dev for squashed migrations)"
  task :up, [:group, :skiima_env] => :setup do |t,args|
    args.with_defaults(:skiima_env => 'development', :group => 'default')
    Skiima.up(args.skiima_env.to_sym, args.group.to_sym)
  end

  desc "Runs Skiima.down for :default group in dependencies.yml"
  task :down, [:group, :skiima_env] => :setup do |t,args|
    args.with_defaults(:skiima_env => 'development', :group => 'default')
    Skiima.down(args.skiima_env.to_sym, args.group.to_sym)
  end

  namespace :test do
    desc "Runs Skiima.up for :test group in dependencies.yml (Run on CI for squashed migrations)"
    task :up, [:group, :skiima_env] => :setup do |t,args|
      args.with_defaults(:skiima_env => 'test', :group => 'test')
      Skiima.up(args.skiima_env.to_sym, args.group.to_sym)
    end

    desc "Runs Skiima.down for :test group in dependencies.yml"
    task :down, [:group, :skiima_env] => :setup do |t,args|
      args.with_defaults(:skiima_env => 'test', :group => 'test')
      Skiima.down(args.skiima_env.to_sym, args.group.to_sym)
    end
  end

end
