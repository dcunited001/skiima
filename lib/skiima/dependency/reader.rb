module Skiima
  module Dependency

    class Reader
      attr_accessor :scripts
      attr_accessor :dependencies, :adapter, :version

      def initialize(dependencies, adapter, opts = {})
        @dependencies, @adapter = dependencies, adapter.to_sym
        @version = opts[:version] || :current
      end

      def adapter
        case @adapter.to_s
          when 'mysql', 'mysql2' then :mysql
          else @adapter
        end
      end

      def get_group(g)
        raise Skiima::SqlGroupNotFound unless dependencies.has_key?(g)
        dependencies[g]
      end

      def get_adapter(grp)
        grp.has_key?(adapter) ? (grp[adapter] || {}) : {}
      end

      def get_scripts(group, version_grp)
        scr = (version_grp.has_key?(version) ? (version_grp[version] || {}) : {})
        sc = scr.map {|s| Skiima::Dependency::Script.new(group, adapter, version, s)}
      end

      def get_load_order(*groups)
        groups.pop if groups.last.is_a? Hash
        @scripts = groups.inject([]) do |memo, g|
          grp = Skiima.symbolize_keys(get_group(g))
          grp = Skiima.symbolize_keys(get_adapter(grp))
          memo = memo + get_scripts(g, grp)
        end
      end
    end

  end
end
