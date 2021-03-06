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

# encoding: utf-8
#module Skiima
#  module DbAdapters
#    class Base
#      attr_accessor :version
#
#      def initialize(connection, logger = nil) #:nodoc:
#        super()
#
#        @active              = nil
#        @connection          = connection
#        @in_use              = false
#        @last_use            = false
#        @logger              = logger
#        @visitor             = nil
#      end
#
#      def adapter_name
#        'Base'
#      end
#
#      def supports_ddl_transactions?
#        false
#      end
#
#      # Does this adapter support savepoints? PostgreSQL and MySQL do,
#      # SQLite < 3.6.8 does not.
#      def supports_savepoints?
#        false
#      end
#
#      def active?
#        @active != false
#      end
#
#      # Disconnects from the database if already connected, and establishes a
#      # new connection with the database.
#      def reconnect!
#        @active = true
#      end
#
#      # Disconnects from the database if already connected. Otherwise, this
#      # method does nothing.
#      def disconnect!
#        @active = false
#      end
#
#      # Reset the state of this connection, directing the DBMS to clear
#      # transactions and other connection-related server-side state. Usually a
#      # database-dependent operation.
#      #
#      # The default implementation does nothing; the implementation should be
#      # overridden by concrete adapters.
#      def reset!
#        # this should be overridden by concrete adapters
#      end
#
#      ###
#      # Clear any caching the database adapter may be doing, for example
#      # clearing the prepared statement cache. This is database specific.
#      def clear_cache!
#        # this should be overridden by concrete adapters
#      end
#
#      # Returns true if its required to reload the connection between requests for development mode.
#      # This is not the case for Ruby/MySQL and it's not necessary for any adapters except SQLite.
#      def requires_reloading?
#        false
#      end
#
#      # Checks whether the connection to the database is still active (i.e. not stale).
#      # This is done under the hood by calling <tt>active?</tt>. If the connection
#      # is no longer active, then this method will reconnect to the database.
#      def verify!(*ignored)
#        reconnect! unless active?
#      end
#
#      # Provides access to the underlying database driver for this adapter. For
#      # example, this method returns a Mysql object in case of MysqlAdapter,
#      # and a PGconn object in case of PostgreSQLAdapter.
#      #
#      # This is useful for when you need to call a proprietary method such as
#      # PostgreSQL's lo_* methods.
#      def raw_connection
#        @connection
#      end
#
#      attr_reader :open_transactions
#
#      def increment_open_transactions
#        @open_transactions += 1
#      end
#
#      def decrement_open_transactions
#        @open_transactions -= 1
#      end
#
#      def transaction_joinable=(joinable)
#        @transaction_joinable = joinable
#      end
#
#      def create_savepoint
#      end
#
#      def rollback_to_savepoint
#      end
#
#      def release_savepoint
#      end
#
#      def current_savepoint_name
#        "active_record_#{open_transactions}"
#      end
#
#      # Check the connection back in to the connection pool
#      def close
#        disconnect!
#      end
#
#      # Disconnects from the database if already connected. Otherwise, this
#      # method does nothing.
#      def disconnect!
#        clear_cache!
#        @connection.close rescue nil
#      end
#
#      protected
#
#      def log(sql, name = "SQL", binds = [])
#        @logger.debug("Executing SQL Statement: #{name}")
#        @logger.debug(sql)
#        result = yield
#        @logger.debug("SUCCESS!")
#        result
#      rescue Exception => e
#        message = "#{e.class.name}: #{e.message}: #{sql}"
#        @logger.debug message if @logger
#        exception = translate_exception(e, message)
#        exception.set_backtrace e.backtrace
#        raise exception
#      end
#
#      def translate_exception(e, message)
#        # override in derived class
#        raise "override in derived class"
#      end
#
#    end
#  end
#end