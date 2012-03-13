# encoding: utf-8
module Skiima
  class Base
    attr_accessor :project_root, :project_config_path, :config_file
    attr_accessor :database_config_file, :skiima_path, :depends_file
    attr_accessor :depends_reader, :logger
    attr_accessor :load_order
    attr_accessor :db_config

    def initialize(options = {})
      set_locale(options[:locale] || Skiima.locale)

      @project_root = options[:project_root] || Skiima.project_root
      @project_config_path = options[:project_config_path] || Skiima.project_config_path
      @config_file = options[:config_file] || Skiima.config_file

      config_yml = read_config(self.config_file)
      @database_config_file = options[:database_config_file] || config_yml[:database_config_file] || Skiima.database_config_file
      @skiima_path = options[:skiima_path] || config_yml[:skiima_path] || Skiima.skiima_path
      @depends_file = options[:depends_file] || config_yml[:depends_file] || Skiima.depends_file
      @load_order = options[:load_order] || config_yml[:load_order] || Skiima.load_order

      @database_config = read_database_config(self.database_config_file)
      
      logging_level = options[:logging_level] || config_yml[:logging_level] || Skiima.logging_level
      logging_out = options[:logging_out] || config_yml[:logging_out] || Skiima.logging_out

      @logger = ::Logger.new(get_logger_out(logging_out))
      @logger.level = get_logger_level(logging_level)
    end

    #============================================================
    # Implementation Methods
    #============================================================
    def up(*args)
      scripts = execute_dependency_reader(args)
      execute_loader(:up, scripts)
    end

    def down(*args)
      scripts = execute_dependency_reader(args)
      execute_loader(:down, scripts)
    end

    #============================================================
    # Path Accessors
    #============================================================
    def project_root(get_relative = false)
      @project_root
    end

    def project_config_path(get_relative = false)
      Skiima.get_path(@project_config_path, get_relative, project_root)
    end

    def config_file(get_relative = false)
      Skiima.get_path(@config_file, get_relative, project_config_path)
    end

    def database_config_file(get_relative = false)
      Skiima.get_path(@database_config_file, get_relative, project_config_path)
    end

    def skiima_path(get_relative = false)
      Skiima.get_path(@skiima_path, get_relative, project_root)
    end

    def depends_file(get_relative = false)
      Skiima.get_path(@depends_file, get_relative, skiima_path)
    end

    #============================================================
    # Logging
    #============================================================

    def log_action(msg, &block)
      begin
        logger.debug "[#{Time.now}] Started: #{msg}"
        results = yield
        logger.debug "[#{Time.now}] Finished: #{msg}"
        results
      rescue
        logger.error "[#{Time.now}] Started: #{msg}"
        raise
      end
    end

    private

    def set_locale(locale)
      FastGettext.text_domain = 'skiima'
      FastGettext.locale = locale.to_s
    end

    def get_dependency_reader(opts = {})
      Skiima.const_get("Dependency").const_get("#{self.load_order}").new({:depends_file => self.depends_file}.merge(opts))
    end

    def execute_dependency_reader(*args)
      @depends_reader = get_dependency_reader
      @depends_reader.get_load_order(args)
    end

    def execute_loader(up_or_down, scripts)
      'Great Success!!'
    end

    def get_logger_out(str)
      case str
        when /STDOUT/i then ::STDOUT
        when /STDERR/i then ::STDERR
        else File.join(project_root, str)
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

    #============================================================
    # Reading Config Files
    #============================================================

    def read_config(file)
      Skiima.read_yaml_or_throw(file, MissingFileException, "Could not open Skiima Config! #{file}")
    end

    def read_database_config(file)
      Skiima.read_yaml_or_throw(file, MissingFileException, "Could not open Database Config! #{file}")
    end
  end
end

