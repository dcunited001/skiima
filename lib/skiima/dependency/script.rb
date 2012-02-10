# encoding: utf-8
module Skiima
  module Dependency
    class Script
      attr_accessor :group, :name

      def initialize(group, name)
        @group, @name = group, name
      end
    end
  end
end
