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
    end
  end
end