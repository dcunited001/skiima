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
        opts = groups.last.is_a?(Hash) ? groups.pop : {}
        @scripts = groups.inject([]) do |memo, g|
          grp = get_group(g)
          scripts = if grp.is_a?(Hash) || (opts[:node] == :internal)
            get_scripts(g, Skiima.symbolize_keys(read_script_group(grp)))
          else
            get_load_order(*(grp.map(&:to_sym)), node: :internal)
          end
          memo + scripts
        end
      end

      private

      def read_script_group(leaf_node)
        get_adapter(Skiima.symbolize_keys(leaf_node))
      end
    end

  end
end
