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
          when (direction == :up) then read_upfile(root)
          when (direction == :down && down_script?(root)) then read_downfile(root)
        end
      end

      def interpolate_sql(char, vars = {})
        @sql = Skiima.interpolate_sql(char, @content, vars)
      end

      def down_filename
        filename.sub('.sql', '.drop.sql')
      end

      def read_upfile(root)
        File.open(full_filename(root)).read
      end

      def read_downfile(root)
        File.open(full_down_filename(root)).read
      end

      def full_filename(root)
        File.join(root, group, filename)
      end

      def full_down_filename(root)
        File.join(root, group, down_filename)
      end

      private

      def set_attr(scr_name)
        scr_name = scr_name.split('.')
        @type, @name = scr_name.shift, scr_name.shift
        @attr = scr_name
      end

      def down_script?(root)
        File.exist?(full_down_filename(root))
      end
    end

  end
end
