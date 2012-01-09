# encoding: utf-8
module Skiima

  class << self
    # the set of options passed down to the instance of Skiima::Base
    def instance_options
      path_options + config_options
    end

    def path_options
      [ :project_root,
        :project_config_path,
        :config_file,
        :database_config_file,
        :skiima_path,
        :depends_file,
        :locale_path ]
    end

    def config_options
      [ :load_order,
        :locale,
        :debug ]
    end
  end

  class Base
    attr_accessor *Skiima.instance_options

    def initialize(options = {})
      Skiima.path_options.each do |opt|
        instance_variable_set("@#{opt.to_s}", (options[opt] || Skiima.send(opt.to_s, true)))
      end

      Skiima.config_options.each do |opt|
        instance_variable_set("@#{opt.to_s}", (options[opt] || Skiima.send(opt.to_s)))
      end
    end

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

    def locale_path(get_relative = false)
      Skiima.get_path(@locale_path, get_relative, project_root)
    end

    def locale_file(get_relative = false)
      Skiima.get_path("skiima.#{locale.to_s}.yml", get_relative, locale_path)
    end
  end
end

