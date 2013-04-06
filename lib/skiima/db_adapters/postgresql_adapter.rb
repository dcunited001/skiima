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

      # Is this connection alive and ready for queries?
      def active?
        @connection.status == PGconn::CONNECTION_OK
      rescue PGError
        false
      end

      # Close then reopen the connection.
      def reconnect!
        clear_cache!
        @connection.reset
        configure_connection
      end

      def reset!
        clear_cache!
        super
      end

      # Disconnects from the database if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        clear_cache!
        @connection.close rescue nil
      end

      # Enable standard-conforming strings if available.
      def set_standard_conforming_strings
        old, self.client_min_messages = client_min_messages, 'panic'
        execute('SET standard_conforming_strings = on', 'SCHEMA') rescue nil
      ensure
        self.client_min_messages = old
      end

      def supported_objects
        [:database, :schema, :table, :view, :rule, :index]
      end

      def database_exists?(name, opts = {})
        query(Skiima.interpolate_sql('&', <<-SQL, { :database => name }))[0][0].to_i > 0
          SELECT COUNT(*) 
          FROM pg_databases pdb 
          WHERE pdb.datname = '&database'
        SQL
      end

      def schema_exists?(name, opts = {}) 
        query(Skiima.interpolate_sql('&', <<-SQL, { :schema => name }))[0][0].to_i > 0
          SELECT COUNT(*)
          FROM pg_namespace
          WHERE nspname = '&schema'
        SQL
      end

      def table_exists?(name, opts = {})
        schema, table = Utils.extract_schema_and_table(name.to_s)
        vars = { :table => table, 
          :schema => ((schema && !schema.empty?) ? "'#{schema}'" : "ANY (current_schemas(false))") }

        vars.inspect

        query(Skiima.interpolate_sql('&', <<-SQL, vars))[0][0].to_i > 0
          SELECT COUNT(*)
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind in ('r')
          AND c.relname = '&table'
          AND n.nspname = &schema
        SQL
      end

      def view_exists?(name, opts = {})
        schema, view = Utils.extract_schema_and_table(name.to_s)
        vars = { :view => view, 
          :schema => ((schema && !schema.empty?) ? "'#{schema}'" : "ANY (current_schemas(false))") }

        query(Skiima.interpolate_sql('&', <<-SQL, vars))[0][0].to_i > 0
          SELECT COUNT(*)
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind in ('v')
          AND c.relname = '&view'
          AND n.nspname = &schema
        SQL
      end

      def rule_exists?(name, opts = {})
        target = opts[:attr] ? opts[:attr][0] : nil
        raise "requires target object" unless target
        schema, rule = Utils.extract_schema_and_table(name.to_s)
        vars = { :rule => rule, 
          :target => target,
          :schema => ((schema && !schema.empty?) ? "'#{schema}'" : "ANY (current_schemas(false))") }

        query(Skiima.interpolate_sql('&', <<-SQL, vars))[0][0].to_i > 0
          SELECT COUNT(*)
          FROM pg_rules pgr
          WHERE pgr.rulename = '&rule'
          AND pgr.tablename = '&target'
          AND pgr.schemaname = &schema
        SQL
      end

      def index_exists?(name, opts = {})
        target = opts[:attr] ? opts[:attr][0] : nil
        raise "requires target object" unless target
        schema, index = Utils.extract_schema_and_table(name.to_s)
        vars = { :index => index, 
          :target => target,
          :schema => ((schema && !schema.empty?) ? "'#{schema}'" : "ANY (current_schemas(false))") }

        query(Skiima.interpolate_sql('&', <<-SQL, vars))[0][0].to_i > 0
          SELECT COUNT(*)
          FROM pg_indexes pgr
          WHERE pgr.indexname = '&index'
          AND pgr.tablename = '&target'
          AND pgr.schemaname = &schema
        SQL
      end

      def drop_database(name, opts = {})
        "DROP DATABASE IF EXISTS #{name}"
      end

      def drop_schema(name, opts = {})
        "DROP SCHEMA IF EXISTS #{name}"
      end

      def drop_table(name, opts = {})
        "DROP TABLE IF EXISTS #{name}"
      end

      def drop_view(name, opts = {})
        "DROP VIEW IF EXISTS #{name}"
      end

      def drop_rule(name, opts = {})
        target = opts[:attr].first if opts[:attr]
        raise "requires target object" unless target

        "DROP RULE IF EXISTS #{name} ON #{target}"
      end

      def drop_index(name, opts = {})
        "DROP INDEX IF EXISTS #{name}"
      end

      class PgColumn
        attr_accessor :name, :deafult, :type, :null
        def initialize(name, default = nil, type = nil, null = true)
          @name, @default, @type, @null = name, default, type, null
        end

        def to_s
          # to be implemented
        end
      end

      # Returns the list of a table's column names, data types, and default values.
      #
      # The underlying query is roughly:
      #  SELECT column.name, column.type, default.value
      #    FROM column LEFT JOIN default
      #      ON column.table_id = default.table_id
      #     AND column.num = default.column_num
      #   WHERE column.table_id = get_table_id('table_name')
      #     AND column.num > 0
      #     AND NOT column.is_dropped
      #   ORDER BY column.num
      #
      # If the table name is not prefixed with a schema, the database will
      # take the first match from the schema search path.
      #
      # Query implementation notes:
      #  - format_type includes the column size constraint, e.g. varchar(50)
      #  - ::regclass is a function that gives the id for a table name
      def column_definitions(table_name) #:nodoc:
        query(<<-SQL, 'SCHEMA')
          SELECT a.attname, format_type(a.atttypid, a.atttypmod), d.adsrc, a.attnotnull
            FROM pg_attribute a LEFT JOIN pg_attrdef d
              ON a.attrelid = d.adrelid AND a.attnum = d.adnum
           WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
             AND a.attnum > 0 AND NOT a.attisdropped
           ORDER BY a.attnum
        SQL
      end

      def column_names(table_name)
        cols = column_definitions(table_name).map do |c|
          PgColumn.new(c[0], c[1], c[2], c[3])
        end
        cols.map(&:name)
      end

      # Checks the following cases:
      #
      # - table_name
      # - "table.name"
      # - schema_name.table_name
      # - schema_name."table.name"
      # - "schema.name".table_name
      # - "schema.name"."table.name"
      def quote_table_name(name)
        schema, name_part = extract_pg_identifier_from_name(name.to_s)

        unless name_part
          quote_column_name(schema)
        else
          table_name, name_part = extract_pg_identifier_from_name(name_part)
          "#{quote_column_name(schema)}.#{quote_column_name(table_name)}"
        end
      end

      # Quotes column names for use in SQL queries.
      def quote_column_name(name) #:nodoc:
        PGconn.quote_ident(name.to_s)
      end

      def extract_pg_identifier_from_name(name)
        match_data = name.start_with?('"') ? name.match(/\"([^\"]+)\"/) : name.match(/([^\.]+)/)

        if match_data
          rest = name[match_data[0].length, name.length]
          rest = rest[1, rest.length] if rest.start_with? "."
          [match_data[1], (rest.length > 0 ? rest : nil)]
        end
      end

      # Executes an SQL statement, returning a PGresult object on success
      # or raising a PGError exception otherwise.
      def execute(sql, name = nil)
        # split on --==== (like in mysql_adapter?)
        log(sql, name) do
          @connection.async_exec(sql)
        end
      end

      # Queries the database and returns the results in an Array-like object
      def query(sql, name = nil) #:nodoc:
        log(sql, name) do
          result_as_array @connection.async_exec(sql)
        end
      end

      # create a 2D array representing the result set
      def result_as_array(res) #:nodoc:
        # check if we have any binary column and if they need escaping
        ftypes = Array.new(res.nfields) do |i|
          [i, res.ftype(i)]
        end

        rows = res.values
        return rows unless ftypes.any? { |_, x|
          x == BYTEA_COLUMN_TYPE_OID || x == MONEY_COLUMN_TYPE_OID
        }

        typehash = ftypes.group_by { |_, type| type }
        binaries = typehash[BYTEA_COLUMN_TYPE_OID] || []
        monies   = typehash[MONEY_COLUMN_TYPE_OID] || []

        rows.each do |row|
          # unescape string passed BYTEA field (OID == 17)
          binaries.each do |index, _|
            row[index] = unescape_bytea(row[index])
          end

          # If this is a money type column and there are any currency symbols,
          # then strip them off. Indeed it would be prettier to do this in
          # PostgreSQLColumn.string_to_decimal but would break form input
          # fields that call value_before_type_cast.
          monies.each do |index, _|
            data = row[index]
            # Because money output is formatted according to the locale, there are two
            # cases to consider (note the decimal separators):
            #  (1) $12,345,678.12
            #  (2) $12.345.678,12
            case data
            when /^-?\D+[\d,]+\.\d{2}$/  # (1)
              data.gsub!(/[^-\d.]/, '')
            when /^-?\D+[\d.]+,\d{2}$/  # (2)
              data.gsub!(/[^-\d,]/, '').sub!(/,/, '.')
            end
          end
        end
      end

      # Set the authorized user for this session
      # def session_auth=(user)
      #   clear_cache!
      #   exec_query "SET SESSION AUTHORIZATION #{user}"
      # end

      # Begins a transaction.
      def begin_db_transaction
        execute "BEGIN"
      end

      # # Commits a transaction.
      def commit_db_transaction
        execute "COMMIT"
      end

      # # Aborts a transaction.
      def rollback_db_transaction
        execute "ROLLBACK"
      end

      def outside_transaction?
        @connection.transaction_status == PGconn::PQTRANS_IDLE
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

      # Returns the current database name.
      def current_database
        query('select current_database()')[0][0]
      end

      # # Returns the current schema name.
      def current_schema
        query('SELECT current_schema', 'SCHEMA')[0][0]
      end

      # Returns the current client message level.
      def client_min_messages
        query('SHOW client_min_messages', 'SCHEMA')[0][0]
      end

      # Set the client message level.
      def client_min_messages=(level)
        execute("SET client_min_messages TO '#{level}'", 'SCHEMA')
      end

      # def reset_pk_sequence!(table, pk = nil, sequence = nil) #:nodoc:
        # need to be able to reset sequences?

      # Sets the schema search path to a string of comma-separated schema names.
      # Names beginning with $ have to be quoted (e.g. $user => '$user').
      # See: http://www.postgresql.org/docs/current/static/ddl-schemas.html
      #
      # This should be not be called manually but set in database.yml.
      def schema_search_path=(schema_csv)
        if schema_csv
          execute "SET search_path TO #{schema_csv}"
          @schema_search_path = schema_csv
        end
      end

      module Utils
        extend self

        # Returns an array of <tt>[schema_name, table_name]</tt> extracted from +name+.
        # +schema_name+ is nil if not specified in +name+.
        # +schema_name+ and +table_name+ exclude surrounding quotes (regardless of whether provided in +name+)
        # +name+ supports the range of schema/table references understood by PostgreSQL, for example:
        #
        # * <tt>table_name</tt>
        # * <tt>"table.name"</tt>
        # * <tt>schema_name.table_name</tt>
        # * <tt>schema_name."table.name"</tt>
        # * <tt>"schema.name"."table name"</tt>
        def extract_schema_and_table(name)
          table, schema = name.scan(/[^".\s]+|"[^"]*"/)[0..1].collect{|m| m.gsub(/(^"|"$)/,'') }.reverse
          [schema, table]
        end
      end

      protected

      # Returns the version of the connected PostgreSQL server.
      def postgresql_version
        @connection.server_version
      end

      def check_psql_version
        @version = postgresql_version
        if @version < 80200
          raise "Your version of PostgreSQL (#{postgresql_version}) is too old, please upgrade!"
        end
      end

      def get_timezone
        execute('SHOW TIME ZONE', 'SCHEMA').first["TimeZone"]
      end

      def translate_exception(e, message)
        e
        # case exception.message
        # when /duplicate key value violates unique constraint/
        #   RecordNotUnique.new(message, exception)
        # when /violates foreign key constraint/
        #   InvalidForeignKey.new(message, exception)
        # else
        #   super
        # end
      end

      private 

      # Connects to a PostgreSQL server and sets up the adapter depending on the
      # connected server's characteristics.
      def connect
        @connection = PGconn.connect(*@connection_parameters)

        # Money type has a fixed precision of 10 in PostgreSQL 8.2 and below, and as of
        # PostgreSQL 8.3 it has a fixed precision of 19. PostgreSQLColumn.extract_precision
        # should know about this but can't detect it there, so deal with it here.
        # PostgreSQLColumn.money_precision = (postgresql_version >= 80300) ? 19 : 10

        configure_connection
      end

      # Configures the encoding, verbosity, schema search path, and time zone of the connection.
      # This is called by #connect and should not be called manually.
      def configure_connection
        if @config[:encoding]
          @connection.set_client_encoding(@config[:encoding])
        end
        self.client_min_messages = @config[:min_messages] if @config[:min_messages]
        self.schema_search_path = @config[:schema_search_path] || @config[:schema_order]

        # Use standard-conforming strings if available so we don't have to do the E'...' dance.
        set_standard_conforming_strings

        #configure the connection to return TIMESTAMP WITH ZONE types in UTC.
        execute("SET time zone '#{@local_tz}'", 'SCHEMA') if @local_tz
      end
    end
  end
end
