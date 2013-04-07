# encoding: utf-8
require 'skiima/db_adapters/base_mysql_adapter'

gem 'mysql', '~> 2.9.1'
require 'mysql'

class Mysql
  class Time
    ###
    # This monkey patch is for test_additional_columns_from_join_table
    def to_date
      Date.new(year, month, day)
    end
  end
  class Stmt; include Enumerable end
  class Result; include Enumerable end
end

module Skiima
  # Establishes a connection to the database that's used by all Active Record objects.
  def self.mysql_connection(logger, config) # :nodoc:
    config = Skiima.symbolize_keys(config)
    host     = config[:host]
    port     = config[:port]
    socket   = config[:socket]
    username = config[:username] ? config[:username].to_s : 'root'
    password = config[:password].to_s
    database = config[:database]

    mysql = Mysql.init
    mysql.ssl_set(config[:sslkey], config[:sslcert], config[:sslca], config[:sslcapath], config[:sslcipher]) if config[:sslca] || config[:sslkey]

    default_flags = Mysql.const_defined?(:CLIENT_MULTI_RESULTS) ? Mysql::CLIENT_MULTI_RESULTS : 0
    default_flags |= Mysql::CLIENT_FOUND_ROWS if Mysql.const_defined?(:CLIENT_FOUND_ROWS)

    options = [host, username, password, database, port, socket, default_flags]
    Skiima::DbAdapters::MysqlAdapter.new(mysql, logger, options, config)
  end

  module DbAdapters
    class MysqlAdapter < BaseMysqlAdapter
      attr_accessor :client_encoding

      ADAPTER_NAME = 'MySQL'

      # def exec_without_stmt(sql, name = 'SQL') # :nodoc:
      #   # Some queries, like SHOW CREATE TABLE don't work through the prepared
      #   # statement API. For those queries, we need to use this method. :'(
      #   log(sql, name) do
      #     result = @connection.query(sql)
      #     cols = []
      #     rows = []

      #     if result
      #       cols = result.fetch_fields.map { |field| field.name }
      #       rows = result.to_a
      #       result.free
      #     end
      #     ActiveRecord::Result.new(cols, rows)
      #   end
      # end

      def execute_and_free(sql, name = nil)
        result = execute(sql, name)
        ret = yield result
        result.free
        ret
      end

      def begin_db_transaction #:nodoc:
        exec_without_stmt "BEGIN"
      rescue Mysql::Error
        # Transactions aren't supported
      end

      private

      def exec_stmt(sql, name)
        stmt = @connection.prepare(sql)

        begin
          stmt.execute
        rescue Mysql::Error => e
          # Older versions of MySQL leave the prepared statement in a bad
          # place when an error occurs. To support older mysql versions, we
          # need to close the statement and delete the statement from the
          # cache.
          stmt.close
          raise e
        end

        cols = nil
        if metadata = stmt.result_metadata
          cols = metadata.fetch_fields.map { |field| field.name }
        end

        result = yield [cols, stmt]

        stmt.result_metadata.free if cols
        stmt.free_result
        stmt.close

        result
      end

      def connect
        encoding = @config[:encoding]
        if encoding
          @connection.options(Mysql::SET_CHARSET_NAME, encoding) rescue nil
        end

        if @config[:sslca] || @config[:sslkey]
          @connection.ssl_set(@config[:sslkey], @config[:sslcert], @config[:sslca], @config[:sslcapath], @config[:sslcipher])
        end

        @connection.options(Mysql::OPT_CONNECT_TIMEOUT, @config[:connect_timeout]) if @config[:connect_timeout]
        @connection.options(Mysql::OPT_READ_TIMEOUT, @config[:read_timeout]) if @config[:read_timeout]
        @connection.options(Mysql::OPT_WRITE_TIMEOUT, @config[:write_timeout]) if @config[:write_timeout]

        @connection.real_connect(*@connection_options)

        # reconnect must be set after real_connect is called, because real_connect sets it to false internally
        @connection.reconnect = !!@config[:reconnect] if @connection.respond_to?(:reconnect=)

        version #gets version

        configure_connection
      end

      def configure_connection
        encoding = @config[:encoding]
        execute("SET NAMES '#{encoding}'", :skip_logging) if encoding

        # By default, MySQL 'where id is null' selects the last inserted id.
        # Turn this off. http://dev.rubyonrails.org/ticket/6778
        execute("SET SQL_AUTO_IS_NULL=0", :skip_logging)
      end
    end
  end
end
