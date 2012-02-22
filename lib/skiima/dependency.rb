# encoding: utf-8
module Skiima
  module Dependency
    class Script
      attr_accessor :group, :name

      def initialize(group, name)
        @group, @name = group, name
      end
    end

    class Reader
      attr_accessor :sql_scripts
      attr_accessor :depends_config
      attr_accessor :object_types

      def initialize(options = {})
        @depends_config = read_depends_file(options[:depends_file])
        @object_types = options[:object_types] || get_object_types(options[:adapter])
      end

      def execute
        raise "Implement Dependency::Reader"
      end

      def get_load_order(*groups)
        raise "Implement Dependency::Reader"
      end

      def get_object_types(adapter)

      end

      def read_depends_file(file)
        begin
          YAML::load_file(file) || {}
        rescue => ex
          # I know I can override Errno::XYZ,
          #   but my goal here is to provide
          #   a friendly error message
          raise MissingFileException, "Could not open Dependencies Config! #{file}"
        end
      end
    end

    class Sequential < Reader
      #@sql_object_names = options[:sql_scripts].map { |s| s.gsub(/\.sql/) }
      #@depends_config = options[:depends_config]
      #@object_types_order = options[:object_types_order]

      def get_load_order(*groups)                                  
        load_order = []
        groups.each do |g|
          raise Skiima::SqlGroupNotFound unless depends_config.has_key?(g)
          sql_scripts()
          load_order + depends_config[g].map  if depends.hash
        end

        temp_sql_objects = sort_objects(sql_objects)
        dep_load_order = @depends_config.keys.each_with_object(Array.new) do |k, load_order|
          index_of_obj = temp_sql_objects.index { |obj| (obj.object_name == k) }

          if index_of_obj
            load_order << temp_sql_objects.delete_at(index_of_obj)
          else
            raise "SQL Object Not Found When Reading Load Order (#{k})"
          end
        end

        #now throw back in the rest of the objects that weren't specified
        dep_load_order + temp_sql_objects
      end
    end

    class Tree < Reader
      def get_load_order(sql_objects)
        raise "Dependency::Tree not yet implemented"
      end
    end
  end
end
