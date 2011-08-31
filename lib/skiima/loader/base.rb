module Skiima
  module Loader
    class Base
      attr_accessor :sql_scripts, {}

      def initialize(options = {})
        scripts = get_sql_scripts

        @sql_scripts =
        @sql_objects = get_sql_objects
      end

      def create

      end

      def drop

      end

      def relative_class_name
        name.to_s.split('::').last
      end

      def table_name
        relative_class_name.underscore.pluralize
      end

      private

      def get_sql_scripts
        Dir[File.join(Skiima.skiima_path, table_name, '*.sql')]
      end

      def get_sql_objects(scripts)
        scripts.each_with_object(Hash.new) {|s,objects|
          objects[s] =
        }

        @sql_scripts.each {|s|

        }
      end

      def parse_object_type_and_name(script)

      end
    end
  end
end
