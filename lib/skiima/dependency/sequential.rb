module Skiima
  module Dependency
    class Sequential < Reader

      def get_load_order(sql_objects)
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
  end
end
