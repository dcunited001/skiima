# encoding: utf-8
require 'skiima/version'

require 'yaml'
require 'logger'
require 'fast_gettext'

require 'skiima_helpers'

# include FastGettext unless it already is
include FastGettext unless ::Object.included_modules.include?(FastGettext)

module Skiima
  include FastGettext::Translation
  extend SkiimaHelpers
  extend ModuleHelpers

  # require 'skiima/base'
  autoload :Dependency, 'skiima/dependency'
  autoload :DbAdapters, 'skiima/db_adapters'

  set_defaults(:config, {
    :root_path => 'specify/in/config/block',
    :config_path => 'config',
    :database_yaml => 'database.yml',
    :scripts_path => 'db/skiima',
    :depends_yaml => 'depends.yml',
    :interpolator => '&',
    :locale => 'en',
    :logging_out => 'STDOUT',
    :logging_level => '3' })
  #should time zone be added to configs?

  class << self
    def setup
      yield self
      set_translation_repository
    end

    def new(env, opts = {})
      Skiima::Loader.new(env, opts)
    end

    def up(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      ski = Skiima.new(env, opts).up(*args)
    ensure 
      ski.connection.close
    end

    def down(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      Skiima.new(env, opts).down(*args)
    ensure
      ski.connection.close
    end

    def msg(*args)
      locale = args.last.is_a?(Symbol) ? args.pop : default_locale
      lookup = args.join('.')
      Skiima._(lookup)
    end

    def log_message(logger, msg)
      logger.debug msg
    end

    def default_locale
      ::Skiima.locale
    end

    def set_translation_repository
      FastGettext.add_text_domain('skiima', :path => File.join(File.dirname(__FILE__), 'skiima', 'locales'), :type => :yaml)
      Skiima.text_domain = 'skiima'
      Skiima.locale = locale.to_s
    end

    def self.exe_with_connection(db, &block)
      resolver = Skiima::DbAdapters::Resolver.new db
      connection = nil

      begin 
        connection = self.send(resolver.adapter_method, db)
        yield connection
      rescue => ex
        puts "Oh Noes!!"
      ensure
        connection.close
      end
    end

    def interpolate_sql(char, sql, vars = {})
      vars.inject(sql) do |memo, (k,v)| 
        memo = memo.gsub("#{char}#{k.to_s}", v)
      end
    end

    def full_scripts_path(root = self.root_path, config = self.scripts_path)
      File.join(root, config)
    end

    def full_database_path(root = self.root_path, config = self.config_path, db = self.database_yaml)
      File.join(root, config, db)
    end

    def full_depends_path(root = self.root_path, config = self.scripts_path, depends = self.depends_yaml)
      File.join(root, config, depends)
    end

    def read_db_yaml(file)
      Skiima.symbolize_keys(self.read_yaml_or_throw(file, MissingFileException, "#{Skiima.msg('errors.open_db_yaml')} #{file}"))
    end

    def read_depends_yaml(file)
      Skiima.symbolize_keys(self.read_yaml_or_throw(file, MissingFileException, "#{Skiima.msg('errors.open_depends_yaml')} #{file}"))
    end

    def read_sql_file(folder, file)
      File.open(File.join(Skiima.full_scripts_path, folder, file)).read
    end

    def read_yaml_or_throw(file, errclass, errmsg)
      yaml = begin
        YAML::load_file(file) || {}
      rescue => ex
        raise errclass, errmsg
      end

      Skiima.symbolize_keys(yaml)
    end

    def method_missing(method, *args, &block)
      setter = method.to_s.gsub(/=$/, '').to_sym if method.to_s =~ /=$/

      val = case
        when (@@config.keys.include?(method)) then @@config[method]
        when (setter and @@config.keys.include?(setter)) then @@config[setter] = args.first
      end

      val || super
    end
  end

  #BaseExceptions
  class BaseException < ::StandardError; end
  class MissingFileException < BaseException; end
  class SqlGroupNotFound < BaseException; end
  class SqlScriptNotFound < BaseException; end

  #DbAdapterExceptions
  class AdapterNotSpecified < BaseException; end
  class LoadError < BaseException; end

  class Loader
    attr_accessor :config, :logger
    attr_accessor :db, :connection
    attr_accessor :scripts

    def initialize(env, opts = {})
      self.config = Skiima.config.merge(opts)
      create_logger
      @db = Skiima.symbolize_keys(Skiima.read_db_yaml(full_database_path)[env])
      make_connection
      @depends = Skiima.read_depends_yaml(full_depends_path)
    end

    def up(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      reader = Skiima::Dependency::Reader.new(@depends, @db[:adapter], opts)
      scripts = reader.get_load_order(*args)
      scripts.each do |s|
        s.read_content(:up, full_scripts_path)
        s.interpolate_sql(interpolator, interpolation_vars)
      end
      scripts.each {|s| connection.execute(s.sql)}
    end

    def down(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      reader = Skiima::Dependency::Reader.new(@depends, @db[:adapter], opts)
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
      @connection = Skiima.send(resolver.adapter_method, logger, @db)
    end

    def log_action(msg, &block)
      begin
        logger.debug "[#{Time.now}] Started: #{msg}"
        results = yield
        logger.debug "[#{Time.now}] Finished: #{msg}"
        results
      rescue
        logger.error "[#{Time.now}] Error: #{msg}"
        raise
      end
    end

    def log_message(msg)
      Skiima.log_message(logger, msg)
    end

    def interpolation_vars(vars = {}) 
      { :database => db[:database] }.merge(vars)
    end

    def method_missing(method, *args, &block)
      setter = method.to_s.gsub(/=$/, '').to_sym if method.to_s =~ /=$/

      val = case 
        when (@config.keys.include?(method)) then @config[method]
        when (setter and @config.keys.include?(setter)) then @config[setter] = args
      end

      val || super
    end

    private

    def full_database_path
      Skiima.full_database_path(self.root_path, self.config_path, self.database_yaml)
    end

    def full_depends_path
      Skiima.full_depends_path(self.root_path, self.scripts_path, self.depends_yaml)
    end

    def full_scripts_path
      Skiima.full_scripts_path(self.root_path, self.scripts_path)
    end

    def get_logger_out(str)
      case str
        when /STDOUT/i then ::STDOUT
        when /STDERR/i then ::STDERR
        else File.join(root_path, str)
      end
    end

    def get_logger_level(str)
      case str
        when '4', /fatal/i then ::Logger::FATAL
        when '3', /error/i then ::Logger::ERROR
        when '2', /warn/i  then ::Logger::WARN
        when '1', /info/i  then ::Logger::INFO
        when '0', /debug/i then ::Logger::DEBUG
        else ::Logger::ERROR
      end
    end

    def create_logger
      self.logger = ::Logger.new(get_logger_out(@config[:logging_out]))
      self.logger.level = get_logger_level(@config[:logging_level])
    end
  end
end
