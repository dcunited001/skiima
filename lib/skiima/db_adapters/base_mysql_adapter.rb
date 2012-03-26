# encoding: utf-8
module Skiima
  module DbAdapters 
    class BaseMysqlAdapter < Base
      attr_accessor :version

      LOST_CONNECTION_ERROR_MESSAGES = [
        "Server shutdown in progress",
        "Broken pipe",
        "Lost connection to MySQL server during query",
        "MySQL server has gone away" ]

      # FIXME: Make the first parameter more similar for the two adapters
      def initialize(connection, logger, connection_options, config)
        super(connection, logger)
        @connection_options, @config = connection_options, config
        @quoted_column_names, @quoted_table_names = {}, {}
      end

      def version
        @version ||= @connection.info[:version].scan(/^(\d+)\.(\d+)\.(\d+)/).flatten.map { |v| v.to_i }
      end

      def adapter_name #:nodoc:
        self.class::ADAPTER_NAME
      end

      # Returns true, since this connection adapter supports migrations.
      def supports_migrations?
        true
      end

      def supports_primary_key?
        true
      end

      # Returns true, since this connection adapter supports savepoints.
      def supports_savepoints?
        true
      end

      # Must return the Mysql error number from the exception, if the exception has an
      # error number.
      def error_number(exception) # :nodoc:
        raise NotImplementedError
      end

      def disable_referential_integrity(&block) #:nodoc:
        old = select_value("SELECT @@FOREIGN_KEY_CHECKS")

        begin
          update("SET FOREIGN_KEY_CHECKS = 0")
          yield
        ensure
          update("SET FOREIGN_KEY_CHECKS = #{old}")
        end
      end

      # MysqlAdapter has to free a result after using it, so we use this method to write
      # stuff in a abstract way without concerning ourselves about whether it needs to be
      # explicitly freed or not.
      def execute_and_free(sql, name = nil) #:nodoc:
        yield execute(sql, name)
      end

      # Executes the SQL statement in the context of this connection.
      def execute(sql, name = nil)
        if name == :skip_logging
          @connection.query(sql)
        else
          log(sql, name) { @connection.query(sql) }
        end
      rescue StatementInvalid => exception
        if exception.message.split(":").first =~ /Packets out of order/
          raise StatementInvalid, "'Packets out of order' error was received from the database. Please update your mysql bindings (gem install mysql) and read http://dev.mysql.com/doc/mysql/en/password-hashing.html for more information. If you're on Windows, use the Instant Rails installer to get the updated mysql bindings."
        else
          raise
        end
      end

      def begin_db_transaction
        execute "BEGIN"
      rescue Exception
        # Transactions aren't supported
      end

      def commit_db_transaction #:nodoc:
        execute "COMMIT"
      rescue Exception
        # Transactions aren't supported
      end

      def rollback_db_transaction #:nodoc:
        execute "ROLLBACK"
      rescue Exception
        # Transactions aren't supported
      end

      def create_savepoint
        execute("SAVEPOINT #{current_savepoint_name}")
      end

      def rollback_to_savepoint
        execute("ROLLBACK TO SAVEPOINT #{current_savepoint_name}")
      end

      def release_savepoint
        execute("RELEASE SAVEPOINT #{current_savepoint_name}")
      end

      def tables(name = nil, database = nil, like = nil)
        sql = "SHOW FULL TABLES "
        sql << "IN #{database} " if database
        sql << "WHERE table_type = 'BASE TABLE' "
        sql << "LIKE '#{like}' " if like

        execute_and_free(sql, 'SCHEMA') do |result|
          result.collect { |field| field.first }
        end
      end

      def views(name = nil, database = nil, like = nil)
        sql = "SHOW FULL TABLES "
        sql << "IN #{database} " if database
        sql << "WHERE table_type = 'VIEW' "
        sql << "LIKE '#{like}' " if like

        execute_and_free(sql, 'SCHEMA') do |result|
          result.collect { |field| field.first }
        end
      end

      def supported_objects
        [:database, :table, :view, :index]
      end

      def database_exists?(name)
        #stub
      end

      def table_exists?(name)
        return false unless name
        return true if tables(nil, nil, name).any?

        name          = name.to_s
        schema, table = name.split('.', 2)

        unless table # A table was provided without a schema
          table  = schema
          schema = nil
        end

        tables(nil, schema, table).any?
      end

      def view_exists?(name)
        return false unless name
        return true if views(nil, nil, name).any?

        name          = name.to_s
        schema, view = name.split('.', 2)

        unless view # A table was provided without a schema
          view   = schema
          schema = nil
        end

        views(nil, schema, view).any?
      end

      def drop_database(name, opts = {})
        "DROP DATABASE IF EXISTS #{name}"
      end

      def drop_table(name, opts = {})
        "DROP TABLE IF EXISTS #{name}"
      end

      def drop_view(name, opts = {})
        "DROP VIEW IF EXISTS #{name}"
      end

      def current_database
        select_value 'SELECT DATABASE() as db'
      end

      # Returns the database character set.
      def charset
        show_variable 'character_set_database'
      end

      # Returns the database collation strategy.
      def collation
        show_variable 'collation_database'
      end

      def show_variable(name)
        # variables = select_all("SHOW VARIABLES LIKE '#{name}'")
        # variables.first['Value'] unless variables.empty?
      end

      protected

      def translate_exception(exception, message)
        exception
        # case error_number(exception)
        # when 1062
        #   RecordNotUnique.new(message, exception)
        # when 1452
        #   InvalidForeignKey.new(message, exception)
        # else
        #   super
        # end
      end

      private

      def supports_views?
        version[0] >= 5
      end
    end
  end
end