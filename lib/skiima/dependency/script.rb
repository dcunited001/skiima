module Skiima
  module Dependency

    class Script
      attr_accessor :group, :adapter, :version
      attr_accessor :type, :name, :attr
      attr_accessor :filename, :content, :sql

      def initialize(group, adapter, version, scriptname)
        @group, @adapter, @version = group.to_s, adapter.to_s, version.to_s
        set_attr(scriptname)
      end

      def filename
        @filename = [@type,@name,@adapter.to_s,@version,'sql'].join('.')
      end

      def read_content(direction, root)
        @content = case
                     when (direction == :up) then File.open(File.join(root, group, filename)).read
                     when (direction == :down && down_script?) then File.open(File.join(root, group, down_filename)).read
                   end
      end

      def interpolate_sql(char, vars = {})
        @sql = Skiima.interpolate_sql(char, @content, vars)
      end

      private

      def set_attr(scr_name)
        scr_name = scr_name.split('.')
        @type, @name = scr_name.shift, scr_name.shift
        @attr = scr_name
      end

      def down_filename
        filename.sub('.sql', '.drop.sql')
      end

      def down_script?
        File.exist?(down_filename)
      end
    end

  end
end
