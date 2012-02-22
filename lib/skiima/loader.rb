# encoding: utf-8
module Skiima
  module Loader
    class Base
      attr_accessor :sql_scripts
      attr_accessor :db_adapter
      attr_accessor :depends_config
      attr_accessor :depends_reader
      attr_accessor :sql_objects

      def initialize(options = {})
        @db_adapter = options[:db_adapter]
        @db_adapter ||= DbAdapter::Postgresql.new

        Skiima.puts "Reading Sql Scripts for #{relative_class_name}"
        @sql_scripts = get_sql_scripts

        @depends_config = options[:depends_config]

        Skiima.puts "  Creating Dependency Reader"
        @depends_reader = Skiima.supported_dependency_reader_classes[options[:load_order]].new if options[:load_order]
        @depends_reader = Dependency::Sequential.new(
            :sql_object_names => @sql_scripts,
            :depends_config => @depends_config,
            :object_types_order => @db_adapter.supported_object_types)

        Skiima.puts "  Getting SQL Objects"
        @sql_objects = get_sql_objects(@depends_reader.sql_object_names)

        Skiima.puts "  Getting Load Order"
        @sql_objects = @depends_reader.get_load_order(@sql_objects)
      end

      def create
        Skiima.puts "Creating #{relative_class_name} Objects"
        @sql_objects.reverse.each {|obj| obj.create}
      end

      def drop
        Skiima.puts "Creating #{relative_class_name} Objects"
        @sql_objects.reverse.each {|obj| obj.drop}
      end

      def relative_class_name
        name.to_s.split('::').last
      end

      def table_name
        relative_class_name.underscore.pluralize
      end

      private

      #this may belong on the dependency reader class
      def get_sql_objects(load_order)
        load_order.each_with_object(Array.new) do |scr,objects|
          type = parse_object_type(scr)

          objects << @db_adapter.supported_object_classes[type].new
        end
      end

      #returns a symbol representing the object type
      #  there should be a limited number of symbols here
      def parse_object_type(script)
        script.split('_', 2).first.to_sym
      end

      def get_sql_scripts
        Dir[File.join(Skiima.skiima_path, table_name, '*.sql')]
      end
    end
  end
end
