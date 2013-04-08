module Skiima
  module Db
    module Helpers
      module Postgresql
        attr_accessor :local_tz
        #attr_accessor :version

        # skiima
        def supported_objects
          [:database, :schema, :table, :view, :rule, :index]
        end

        def check_psql_version
          @version = postgresql_version
          if @version < 80200
            raise "Your version of PostgreSQL (#{postgresql_version}) is too old, please upgrade!"
          end
        end

        # schema matchers
        def object_exists?(type, name, opts = {})
          send("#{type}_exists?", name, opts) if supported_objects.include? type.to_sym
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
          schema, table = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::Utils.extract_schema_and_table(name.to_s)
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
          schema, view = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::Utils.extract_schema_and_table(name.to_s)
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
          schema, rule = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::Utils.extract_schema_and_table(name.to_s)
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
          schema, index = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::Utils.extract_schema_and_table(name.to_s)
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

        # queries
        def drop(type, name, opts = {})
          send("drop_#{type}", name, opts) if supported_objects.include? type.to_sym
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


        # in original? why?
        #necessary 2 override?
        #def translate_exception(e, message)
        #  e
        #  # case exception.message
        #  # when /duplicate key value violates unique constraint/
        #  #   RecordNotUnique.new(message, exception)
        #  # when /violates foreign key constraint/
        #  #   InvalidForeignKey.new(message, exception)
        #  # else
        #  #   super
        #  # end
        #end

        # necessary 2 override?
        #class PgColumn
        #  attr_accessor :name, :deafult, :type, :null
        #  def initialize(name, default = nil, type = nil, null = true)
        #    @name, @default, @type, @null = name, default, type, null
        #  end
        #
        #  def to_s
        #    # to be implemented
        #  end
        #end
        def column_names(table_name)
          columns(table_name).map(&:name)
        end

        # necessary 2 override?
        ## Close then reopen the connection.
        #def reconnect!
        #  clear_cache!
        #  @connection.reset
        #  configure_connection
        #end

        # necessary 2 override?
        ## Is this connection alive and ready for queries?
        #def active?
        #  @connection.status == PGconn::CONNECTION_OK
        #rescue PGError
        #  false
        #end

        protected

        def get_timezone
          execute('SHOW TIME ZONE', 'SCHEMA').first["TimeZone"]
        end

        private

        #necessary 2 override?
        # Configures the encoding, verbosity, schema search path, and time zone of the connection.
        # This is called by #connect and should not be called manually.
        #def configure_connection
        #  if @config[:encoding]
        #    @connection.set_client_encoding(@config[:encoding])
        #  end
        #  self.client_min_messages = @config[:min_messages] if @config[:min_messages]
        #  self.schema_search_path = @config[:schema_search_path] || @config[:schema_order]
        #
        #  # Use standard-conforming strings if available so we don't have to do the E'...' dance.
        #  set_standard_conforming_strings
        #
        #  #configure the connection to return TIMESTAMP WITH ZONE types in UTC.
        #  execute("SET time zone '#{@local_tz}'", 'SCHEMA') if @local_tz
        #end


      end
    end
  end
end