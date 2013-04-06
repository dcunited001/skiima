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

      def initialize(connection, logger, connection_options, config)
        super
        @client_encoding = nil
        connect
      end

      # # Returns the version of the connected MySQL server.
      def version
        @version ||= @connection.server_info.scan(/^(\d+)\.(\d+)\.(\d+)/).flatten.map { |v| v.to_i }
      end

      # # Returns true, since this connection adapter supports prepared statement
      # # caching.
      def supports_statement_cache?
        true
      end

      def error_number(exception) # :nodoc:
        exception.errno if exception.respond_to?(:errno)
      end

      def type_cast(value, column)
        return super unless value == true || value == false

        value ? 1 : 0
      end

      def quote_string(string) #:nodoc:
        @connection.quote(string)
      end

      def active?
        if @connection.respond_to?(:stat)
          @connection.stat
        else
          @connection.query 'select 1'
        end

        # mysql-ruby doesn't raise an exception when stat fails.
        if @connection.respond_to?(:errno)
          @connection.errno.zero?
        else
          true
        end
      rescue Mysql::Error
        false
      end

      def reconnect!
        disconnect!
        clear_cache!
        connect
      end

      # Disconnects from the database if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        @connection.close rescue nil
      end

      def reset!
        if @connection.respond_to?(:change_user)
          # See http://bugs.mysql.com/bug.php?id=33540 -- the workaround way to
          # reset the connection is to change the user to the same user.
          @connection.change_user(@config[:username], @config[:password], @config[:database])
          configure_connection
        end
      end

      if "<3".respond_to?(:encode)
        # Taken from here:
        #   https://github.com/tmtm/ruby-mysql/blob/master/lib/mysql/charset.rb
        # Author: TOMITA Masahiro <tommy@tmtm.org>
        ENCODINGS = {
          "armscii8" => nil,
          "ascii"    => Encoding::US_ASCII,
          "big5"     => Encoding::Big5,
          "binary"   => Encoding::ASCII_8BIT,
          "cp1250"   => Encoding::Windows_1250,
          "cp1251"   => Encoding::Windows_1251,
          "cp1256"   => Encoding::Windows_1256,
          "cp1257"   => Encoding::Windows_1257,
          "cp850"    => Encoding::CP850,
          "cp852"    => Encoding::CP852,
          "cp866"    => Encoding::IBM866,
          "cp932"    => Encoding::Windows_31J,
          "dec8"     => nil,
          "eucjpms"  => Encoding::EucJP_ms,
          "euckr"    => Encoding::EUC_KR,
          "gb2312"   => Encoding::EUC_CN,
          "gbk"      => Encoding::GBK,
          "geostd8"  => nil,
          "greek"    => Encoding::ISO_8859_7,
          "hebrew"   => Encoding::ISO_8859_8,
          "hp8"      => nil,
          "keybcs2"  => nil,
          "koi8r"    => Encoding::KOI8_R,
          "koi8u"    => Encoding::KOI8_U,
          "latin1"   => Encoding::ISO_8859_1,
          "latin2"   => Encoding::ISO_8859_2,
          "latin5"   => Encoding::ISO_8859_9,
          "latin7"   => Encoding::ISO_8859_13,
          "macce"    => Encoding::MacCentEuro,
          "macroman" => Encoding::MacRoman,
          "sjis"     => Encoding::SHIFT_JIS,
          "swe7"     => nil,
          "tis620"   => Encoding::TIS_620,
          "ucs2"     => Encoding::UTF_16BE,
          "ujis"     => Encoding::EucJP_ms,
          "utf8"     => Encoding::UTF_8,
          "utf8mb4"  => Encoding::UTF_8,
        }
      else
        ENCODINGS = Hash.new { |h,k| h[k] = k }
      end
      
      # Get the client encoding for this database
      def client_encoding
        return @client_encoding if @client_encoding

        result = exec_query(
          "SHOW VARIABLES WHERE Variable_name = 'character_set_client'",
          'SCHEMA')
        @client_encoding = ENCODINGS[result.last.last]
      end

      def execute(sql, name = nil)
        # relying on formatting inside the file is precisely what i wanted to avoid...
        results = sql.split(/^--={4,}/).map do |spider_monkey|
          super(spider_monkey)
        end

        results.first
      end

      def exec_query(sql, name = 'SQL')
        log(sql, name) do
          exec_stmt(sql, name) do |cols, stmt|
            stmt.to_a
          end
        end
      end

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
