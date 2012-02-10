# encoding: utf-8
module Skiima
  module Dependency
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
  end
end
