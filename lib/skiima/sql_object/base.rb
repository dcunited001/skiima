module Skiima
  module SqlObject
    class Base
      attr_accessor :object_type
      attr_accessor :object_name
      attr_accessor :script_name

      def initialize(options = {})
        @script_name = options[:script_name]

        obj_data = parse_object_data
        @object_type = obj_data[:object_type]
        @object_name = obj_data[:object_name]
      end

      def create
        Skiima.puts "  Creating #{object_type.capitalize}: #{object_name.capitalize}"
      end

      def drop
        Skiima.puts "  Dropping #{object_type.capitalize}: #{object_name.capitalize}"
      end

      #needed to get the class name
      #   of classes that inherit
      #   from SqlLoaderBase
      def self.relative_name
        name.to_s.split('::').last
      end

      def get_file_name
        "#{relative_name}_#{@object_name}.sql"
      end

      private

      def parse_object_data
        data = {}

        #Regexp.new("(#{relative_name.underscore})_([:alnum:]).sql")
        script_name_split = @script_name.split('_', 2)

        data[:object_type] = script_name_split[0].to_sym
        name = script_name_split[1]

        if (name =~ /(.*).sql/)
          data[:object_name] = $1
        else
          raise "Invalid File Extension. Scripts must end in '.sql'"
        end
      end

    end
  end
end