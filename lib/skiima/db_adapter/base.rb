module Skiima
  module DbAdapter
    class Base
      def create(sql_object)

      end

      def drop(sql_object)

      end

      #gets an array of supported objects from the
      def supported_objects
        Skiima.supported_objects[relative_name.intern]
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
