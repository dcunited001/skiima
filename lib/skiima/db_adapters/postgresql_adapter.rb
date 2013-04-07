# encoding: utf-8
gem 'pg', '~> 0.11'
require 'pg'

module Skiima
  def self.postgresql_connection(logger, config) # :nodoc:
    config = Skiima.symbolize_keys(config)
    host     = config[:host]
    port     = config[:port] || 5432
    username = config[:username].to_s if config[:username]
    password = config[:password].to_s if config[:password]

    if config.key?(:database)
      database = config[:database]
    else
      raise ArgumentError, "No database specified. Missing argument: database."
    end

    # The postgres drivers don't allow the creation of an unconnected PGconn object,
    # so just pass a nil connection object for the time being.
    Skiima::DbAdapters::PostgresqlAdapter.new(nil, logger, [host, port, nil, nil, database, username, password], config)
  end

  module DbAdapters

    class PostgresqlAdapter < Base
      attr_accessor :version, :local_tz

      ADAPTER_NAME = 'PostgreSQL'

      NATIVE_DATABASE_TYPES = {
        :primary_key => "serial primary key",
        :string      => { :name => "character varying", :limit => 255 },
        :text        => { :name => "text" },
        :integer     => { :name => "integer" },
        :float       => { :name => "float" },
        :decimal     => { :name => "decimal" },
        :datetime    => { :name => "timestamp" },
        :timestamp   => { :name => "timestamp" },
        :time        => { :name => "time" },
        :date        => { :name => "date" },
        :binary      => { :name => "bytea" },
        :boolean     => { :name => "boolean" },
        :xml         => { :name => "xml" },
        :tsvector    => { :name => "tsvector" }
      }

      MONEY_COLUMN_TYPE_OID = 790 # The internal PostgreSQL identifier of the money data type.
      BYTEA_COLUMN_TYPE_OID = 17 # The internal PostgreSQL identifier of the BYTEA data type.

      def adapter_name
        ADAPTER_NAME
      end

      # Initializes and connects a PostgreSQL adapter.
      def initialize(connection, logger, connection_parameters, config)
        super(connection, logger)
        @connection_parameters, @config = connection_parameters, config
        # @visitor = Arel::Visitors::PostgreSQL.new self
        
        # @local_tz is initialized as nil to avoid warnings when connect tries to use it
        @local_tz = nil
        @table_alias_length = nil
        @version = nil

        connect
        check_psql_version
        @local_tz = get_timezone
      end
    end
  end
end
