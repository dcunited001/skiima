# encoding: utf-8
module Skiima

  class << self
    # the set of options passed down to the instance of Skiima::Base
    #     this is defined here because i still need to change
    #     the order in which these files are loaded
    def instance_options
      path_options + config_options
    end

    def path_options
      [ :project_root,
        :project_config_path,
        :config_file,
        :database_config_file,
        :skiima_path,
        :depends_file ]
    end

    def config_options
      [ :load_order,
        :logging_level ]
    end
  end

  class Base
    attr_accessor :project_root, :project_config_path, :config_file
    attr_accessor :database_config_file, :skiima_path, :depends_file
    attr_accessor :load_order, :logging_out, :logging_level

    def initialize(options = {})
      set_locale(options[:locale] || Skiima.locale)

      @project_root = options[:project_root] || Skiima.project_root
      @project_config_path = options[:project_config_path] || Skiima.project_config_path
      @config_file = options[:config_file] || Skiima.config_file

      config_yml = read_config_file(self.config_file)
      @database_config_file = options[:database_config_file] || config_yml[:database_config_file] || Skiima.database_config_file
      @skiima_path = options[:skiima_path] || config_yml['skiima_path'] || Skiima.skiima_path
      @depends_file = options[:depends_file] || config_yml['depends_file'] || Skiima.depends_file

      @load_order = options[:load_order] || config_yml['load_order'] || Skiima.load_order
      @logging_out = options[:logging_out] || config_yml['logging_out'] || Skiima.logging_out
      @logging_level = options[:logging_level] || config_yml['logging_level'] || Skiima.logging_level

      @depends_config = read_depends_file(self.depends_file)
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

    private

    def set_locale(locale)
      FastGettext.text_domain = 'skiima'
      FastGettext.locale = locale.to_s
    end

    #============================================================
    # Reading Config Files
    #============================================================

    def read_config_file(file)
      begin
        YAML::load_file(file) || {}
      rescue => ex
        # I know I can override Errno::XYZ,
        #   but my goal here is to provide
        #   a friendly error message
        raise MissingFileException, "Could not open Skiima Config: #{file}!"
      end
    end

    def read_depends_file(file)
      begin
        YAML::load_file(file) || {}
      rescue => ex
        # I know I can override Errno::XYZ,
        #   but my goal here is to provide
        #   a friendly error message
        raise MissingFileException, "Could not open Dependencies Config: #{file}!"
      end
    end
  end
end

