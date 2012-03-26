# encoding: utf-8
require 'skiima/db_adapters/base_mysql_adapter'

gem 'mysql2', '~> 0.3.10'
require 'mysql2'

module Skiima
  def self.mysql2_connection(logger, config)
    config[:username] = 'root' if config[:username].nil?

    if Mysql2::Client.const_defined? :FOUND_ROWS
      config[:flags] = Mysql2::Client::FOUND_ROWS
    end

    client = Mysql2::Client.new(Skiima.symbolize_keys(config))
    options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
    Skiima::DbAdapters::Mysql2Adapter.new(client, logger, options, config)
  end

  module DbAdapters
    class Mysql2Adapter < BaseMysqlAdapter
      ADAPTER_NAME = 'Mysql2'

      def initialize(connection, logger, connection_options, config)
        super
        configure_connection
      end

      def supports_explain?
        true
      end

      def error_number(exception)
        exception.error_number if exception.respond_to?(:error_number)
      end

      def active?
        return false unless @connection
        @connection.ping
      end

      def reconnect!
        disconnect!
        connect
      end

      # Disconnects from the database if already connected.
      # Otherwise, this method does nothing.
      def disconnect!
        unless @connection.nil?
          @connection.close
          @connection = nil
        end
      end

      def reset!
        disconnect!
        connect
      end

      def execute(sql, name = nil)
        # make sure we carry over any changes to ActiveRecord::Base.default_timezone that have been
        # made since we established the connection
        # @connection.query_options[:database_timezone] = ActiveRecord::Base.default_timezone

        # relying on formatting inside the file is precisely what i wanted to avoid...
        results = sql.split(/^--={4,}/).map do |spider_monkey|
          super(spider_monkey)
        end

        results.first
      end

      def exec_query(sql, name = 'SQL', binds = [])
        result = execute(sql, name)
        ActiveRecord::Result.new(result.fields, result.to_a)
      end

      alias exec_without_stmt exec_query

      private

      def connect
        @connection = Mysql2::Client.new(@config)
        configure_connection
      end

      def configure_connection
        @connection.query_options.merge!(:as => :array)

        variable_assignments = get_var_assignments
        execute("SET #{variable_assignments.join(', ')}", :skip_logging)

        version
      end

      def get_var_assignments
        # By default, MySQL 'where id is null' selects the last inserted id.
        # Turn this off. http://dev.rubyonrails.org/ticket/6778
        variable_assignments = ['SQL_AUTO_IS_NULL=0']
        encoding = @config[:encoding]

        # make sure we set the encoding
        variable_assignments << "NAMES '#{encoding}'" if encoding

        # increase timeout so mysql server doesn't disconnect us
        wait_timeout = @config[:wait_timeout]
        wait_timeout = 2592000 unless wait_timeout.is_a?(Fixnum)
        variable_assignments << "@@wait_timeout = #{wait_timeout}"
      end

    end
  end
end
