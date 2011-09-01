module Skiima
  module Dependency
    class Sequential < Reader

      def get_load_order
        obj_names = @sql_object_names
        dep_load_order = @depends_config.keys.each_with_object(Array.new) do |k, load_order|
          load_order << k if obj_names.delete(k)
        end

        #now throw back in the rest of the objects that weren't specified
        dep_load_order + obj_names
      end
    end
  end
end
