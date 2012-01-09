# encoding: utf-8
module Skiima
  module SqlObject
    class Rule < Base
      attr_accessor :target_object_name
      attr_accessor :rule_action

      def object_name
        "#{@target_object_name}_#{@rule_action}" if (@target_object_name and @rule_action)
      end

      def object_name=(obj_name)
        # this splits the string starting from the right
        #string.reverse.split('.', 2).map(&:reverse).reverse
        split_name = obj_name.reverse.split('_', 2).map(&:reverse).reverse
        @target_object_name = split_name.first
        @rule_action = split_name.last

        attribute_set(:object_name, obj_name)
      end

      def get_file_name
        "#{relative_name}_#{}"
      end
    end
  end
end
