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

    class Reader
      attr_accessor :scripts
      attr_accessor :depends, :adapter, :version

      def initialize(depends, adapter, opts = {})
        @depends, @adapter = depends, adapter.to_sym
        @version = opts[:version] || :current
      end

      def adapter
        case @adapter.to_s
        when 'mysql', 'mysql2' then :mysql
        else @adapter
        end
      end

      def get_group(g)
        raise Skiima::SqlGroupNotFound unless depends.has_key?(g)
        depends[g]
      end

      def get_adapter(grp)
        grp.has_key?(adapter) ? (grp[adapter] || {}) : {}
      end

      def get_scripts(group, version_grp)
        scr = (version_grp.has_key?(version) ? (version_grp[version] || {}) : {})
        sc = scr.map {|s| Skiima::Dependency::Script.new(group, adapter, version, s)}
      end

      def get_load_order(*groups)
        @scripts = groups.inject([]) do |memo, g|
          grp = Skiima.symbolize_keys(get_group(g))
          grp = Skiima.symbolize_keys(get_adapter(grp))
          memo = memo + get_scripts(g, grp)
        end
      end
    end
  end
end
