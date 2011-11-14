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

      table_names = yml["models"].keys
      class_names = table_names.map { |name| name.camelize.singularize }

      @loader_depends = get_dependencies(yml)
      @loader_classes = get_loader_classes(class_names)
    end

    def get_dependencies(depends_yml)
      table_names = depends_yml.keys
      table_names.each_with_object(Hash.new) { |name,hash| hash[name] = depends_yml[name].keys }
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

    #def get_models
    #  ActiveRecord::Base.send(:subclasses).each_with_object(Hash.new) { |m,models| models[m.name.underscore.pluralize] = m }
    #end
  end
end

#  def load_classes(yml_classes)
#    models = get_models
#    Skiima.classes = yml_classes.keys.map do |c|
#      if models.has_key? c
#        models[c]
#      else
#        raise "#{c.camelize.singularize} is not a valid model."
#      end
#    end
#
#    yml_classes.keys.each { |c| ArchiveData.archive_attributes[c] = classes[c] }
#  end
#
#  def get_models
#    Dir[Rails.root.join('app', 'models', '**')].each { |model| require model }
#    models = {}
#    ActiveRecord::Base.send(:subclasses).each { |m| models[m.name.underscore.pluralize] = m }
#  end