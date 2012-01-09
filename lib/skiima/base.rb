# encoding: utf-8
module Skiima
  # the set of options passed down to the instance of Skiima::Base
  def self.instance_options
    [ :project_root,
      :project_config_path,
      :config_file,
      :database_config_file,
      :skiima_path,
      :depends_file,
      :locale_path,

      :load_order,
      :locale,
      :debug ]
  end

  class Base
    attr_accessor *Skiima.instance_options

    define_method(:project_config_path)   { File.join(project_root, instance_variable_get(:@project_config_path)) }
    define_method(:config_file)           { File.join(project_config_path, instance_variable_get(:@config_file)) }
    define_method(:database_config_file)  { File.join(project_config_path, instance_variable_get(:@database_config_file)) }
    define_method(:skiima_path)           { File.join(project_root, instance_variable_get(:@skiima_path)) }
    define_method(:depends_file)          { File.join(skiima_path, instance_variable_get(:@depends_file)) }
    define_method(:locale_path)           { File.join(project_root, instance_variable_get(:@locale_path)) }
    define_method(:locale_file)           { File.join(locale_path, "skiima.#{locale.to_s}.yml") }

    def initialize(options = {})
      Skiima.instance_options.each do |opt|
        instance_variable_set("@#{opt.to_s}", (options[opt] || Skiima.class_variable_get("@@#{opt.to_s}")))
      end
    end
  end
end

