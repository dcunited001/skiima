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
    attr_accessor *Skiima.instance_options

    def initialize(options = {})
      set_locale(options[:locale] || Skiima.locale)

      Skiima.path_options.each do |opt|
        instance_variable_set("@#{opt.to_s}", (options[opt] || Skiima.send(opt.to_s, true)))
      end

      Skiima.config_options.each do |opt|
        instance_variable_set("@#{opt.to_s}", (options[opt] || Skiima.send(opt.to_s)))
      end
    end

    #============================================================
    # Accessors
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
  end
end

