# encoding: utf-8

module Skiima
  module Db
    module Connector
      class Base
        extend Forwardable

        class << self
          extend Forwardable

          def create_connector(config, logger = nil, opts = {})
            pool = config['pool']
            adapter = create_adapter(config, logger, pool)
            new(adapter, logger, config)
          end
        end

        attr_accessor :config, :orm
        attr_accessor :logger, :adapter

        alias_method :klass, :class
        delegate helpers_module: :klass

        def initialize(adapter, logger, config = {})
          @adapter, @logger = adapter, logger

          set_config(config)
          include_helpers_on_adapter
        end

        private

        def set_config(opts = {})
          @config = opts
        end

        def include_helpers_on_adapter
          adapter.singleton_class.class_eval "include #{helpers_module.to_s}"
        end
      end
    end
  end
end