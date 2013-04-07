# encoding: utf-8

module Skiima
  module Db
    module Connector
      class Base
        extend Forwardable
        class << self; extend Forwardable; end

        attr_accessor :config, :version, :orm
        attr_accessor :logger, :adapter

        delegate [:adapter_name, :connection,
                  :supported_objects,
                  :supports_ddl_transactions?,
                  :drop, :active?, :object_exists?,
                  :reconnect!, :disconnect!, :close,
                  :reset!, :verify!, :raw_connection] => :adapter
                  # also include: :transaction_joinable=,
                  # :increment_open_transactions, :decrement_open_transactions,
                  # :create_savepoint, :rollback_to_savepoint
                  # :release_savepoint, :current_savepoint_name

        def initialize(adapter, logger, config = {})
          @adapter = adapter
          @logger = logger

          set_config(config)
          set_version

          #initialize
          #return, and resolver loads instance with methods
        end

        private

        def set_config(opts = {})
          @config = opts
        end

        def set_version
          @version = config[:version] || default_version
        end
      end
    end
  end
end