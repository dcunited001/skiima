module Skiima
  class LoaderConfig
    attr_accessor :messages, :config

    def initialize(opts = {})
      read_config(opts[:config])
      read_locale(opts[:locale])
      read_dependencies(opts[:depends])
    end

    private

    def read_locale(file)
      @messages = YAML::load_file(file)
    end

    def read_config(file)
      @config = YAML::load_file(file) || {}
    end

    def read_dependencies(file)
      yml = YAML::load_file(file)

      table_names = yml.keys
      class_names = table_names.map { |name| name.camelize.singularize }

      @loader_depends = get_dependencies(yml)
      @loader_classes = get_loader_classes(class_names)
    end

    def get_dependencies(depends_yml)
      dependencies = {}
      depends_yml.each_pair do |table, objects|
        if depends_yml[table]
          dependencies[table] = (depends_yml[table].is_a?(Hash) ? depends_yml[table] : { depends_yml[table] => nil })
        else
          dependencies[table] = {}
        end
      end

      raise dependencies.inspect
    end

    def get_loader_classes(class_names)
      class_names.map do |klass_name|
        klass = Class.new Skiima::Loader::Base #do  end   #no block necessary

        unless Skiima::Loader.const_defined?(:"#{klass_name}")
          Object.const_set klass_name, klass
        else
          Skiima::Loader.const_get :"#{klass_name}"
        end
      end
    end
  end
end