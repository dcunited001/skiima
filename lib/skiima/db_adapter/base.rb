module Skiima
  module DbAdapter
    class Base
      attr_accessor :supported_objects
      attr_accessor :supported_object_classes

      def initialize(options = {})
        @supported_objects = options[:supported_objects]
        @supported_objects ||= get_supported_objects

        @supported_object_classes = get_supported_object_classes
      end

      def create(sql_object)

      end

      def drop(sql_object)

      end

      def get_supported_objects
        Skiima.supported_objects[relative_name.to_sym]
      end

      def get_supported_object_classes
        #this needs to change to support more than one level of inheritance
        sql_object_subclasses = Skiima::SqlObject::Base.subclasses
        sql_object_subclasses.each_with_object(Array.new) do |klass, supported_classes|
          supported_classes << klass if supported_objects.include? (klass.relative_name.underscore.to_sym)
        end
      end

      #needed to get the class name
      #   of classes that inherit
      #   from SqlLoaderBase
      def self.relative_name
        name.to_s.split('::').last
      end

      def self.get_adapter_class(db_adapter_sym)
        self.subclasses.each do |sc|
          return sc if sc.relative_name.underscore == db_adapter_sym.to_s
        end
      end
    end
  end
end