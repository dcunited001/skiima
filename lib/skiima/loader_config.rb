module Skiima
  class LoaderConfig
    def initialize(options = {})
      read_locale
      read_config
      read_dependencies
    end

    private

    def read_locale
      yml = YAML::load_file(Skiima.locale_file)
    end

    def read_config
      yml = YAML::load_file(Skiima.skiima_config_file)

      Skiima.load_order = yml[:load_order].to_sym

      #assign to options
    end

    def read_dependencies
      yml = YAML::load_file(Skiima.skiima_depends_file)
      table_names = yml.keys
      class_names = table_names.map { |name| name.camelize.singularize }

      Skiima.loader_depends = get_dependencies(table_names)
      Skiima.loader_classes = get_loader_classes(class_names)
    end

    def get_loader_classes(class_names)
      class_names.map do |klass_name|
        klass = Class.new Skiima::Loader::Base do
          # any model specific code here
        end

        #check to see if there is a file with the singular table name
          #if so, require it
          #otherwise, instantiate the class

        Object.const_set klass_name, klass
      end
    end

    def get_dependencies(depends_yml)
      table_names = depends_yml.keys
      table_names.each_with_object(Hash.new) { |name,hash| hash[name] = depends_yml[name].keys }
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