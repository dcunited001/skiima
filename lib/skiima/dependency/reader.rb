module Skiima
  module Dependency
    class Reader
      attr_accessor :sql_object_names
      attr_accessor :depends_config
      attr_accessor :object_types_order

      def initialize(options = {})
        @sql_object_names = options[:sql_scripts].map { |s| s.gsub(/\.sql/) }
        @depends_config = options[:depends_config]
        @object_types_order = options[:object_types_order]
      end

      def get_load_order(sql_objects)
        raise "Implement Dependency::Reader"
      end

      private

      def self.sort_objects(sql_objects)
        sql_objects.sort {|a,b| @object_types_order.index(b.object_type) <=> @object_types_order.index(a.object_type) }
      end
    end
  end
end