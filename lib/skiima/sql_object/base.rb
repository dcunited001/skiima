module Skiima
  module SqlObject
    class Base
      attr_accessor :object_name

      def get_file_name
        "#{relative_name}_#{@object_name}.sql"
      end

      #needed to get the class name
      #   of classes that inherit
      #   from SqlLoaderBase
      def self.relative_name
        name.to_s.split('::').last
      end
    end
  end
end