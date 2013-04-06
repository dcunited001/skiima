# encoding: utf-8
module Skiima
  class Loader
    include Skiima::Config

    attr_accessor :env, :db, :connection
    attr_accessor :scripts
    attr_accessor :logger

    def defaults
      Skiima.config
    end

    def initialize(env, opts = {})
      @env = env
      db_config = opts.delete('db') || {}
      get_config(opts)
      create_logger
      merge_db_config(db_config)
      make_connection
      get_dependency_config
    end

    def up(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      reader = Skiima::Dependency::Reader.new(@depends, @db['adapter'], opts)
      scripts = reader.get_load_order(*args)
      scripts.each do |s|
        s.read_content(:up, full_scripts_path)
        s.interpolate_sql(interpolator, interpolation_vars)
      end
      scripts.each {|s| connection.execute(s.sql)}
    end

    def down(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      reader = Skiima::Dependency::Reader.new(@depends, @db['adapter'], opts)
      scripts = reader.get_load_order(*args).reverse
      scripts.each do |s|
        s.read_content(:down, full_scripts_path)
        s.content ||= connection.drop(s.type, s.name, {:attr => s.attr}.merge(opts))
        s.interpolate_sql(interpolator, interpolation_vars)
      end
      scripts.each {|s| connection.execute(s.sql)}
    end

    def make_connection
      resolver = Skiima::DbAdapters::Resolver.new(@db)
      @connection = Skiima.send(resolver.adapter_method, logger, db)
    end

    def log_message(msg)
      Skiima.log_message(logger, msg)
    end

    def interpolation_vars
      { :database => db['database'] }.merge(config[:vars] || {})
    end

    def method_missing(method, *args, &block)
      config.respond_to?(method) ? config.send(method, *args) : super
    end

    private

    def get_config(opts)
      @config = config.merge(opts)
    end

    def merge_db_config(db_config)
      @db = read_db_yml(full_database_path)[env].merge(db_config)
    end

    def get_dependency_config
      @depends = read_depends_yml(full_depends_path)
    end

    def create_logger
      @logger = Skiima::Logger.new config.slice(:logging_out, :logging_level)
    end
  end
end
