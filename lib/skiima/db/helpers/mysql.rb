module Skiima
  module Db
    module Helpers
      module Mysql
        #attr_accessor :version

        def supported_objects
          [:database, :table, :view, :index, :proc]
        end

        def execute(sql, name = nil)
          # relying on formatting inside the file is precisely what i wanted to avoid...
          results = sql.split(/^--={4,}/).map do |line|
            super(line)
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

        #override?
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

        def indexes(name = nil, database = nil, table = nil)
          sql = "SHOW INDEX "
          sql << "IN #{table} "
          sql << "IN #{database} " if database
          sql << "WHERE key_name = '#{name}'" if name

          execute_and_free(sql, 'SCHEMA') do |result|
            result.collect { |field| field[2] }
          end
        end

        def procs(name = nil, database = nil, like = nil)
          sql = "SELECT r.routine_name "
          sql << "FROM information_schema.routines r "
          sql << "WHERE r.routine_type = 'PROCEDURE' "
          sql << "AND r.routine_name LIKE '#{like}' " if like
          sql << "AND r.routine_schema = #{database} " if database

          execute_and_free(sql, 'SCHEMA') do |result|
            result.collect { |field| field.first }
          end
        end

        # needed?
        #def column_definitions(table_name)
        #  # "SHOW FULL FIELDS FROM #{quote_table_name(table_name)}"
        #end

        # keep?
        #def column_names(table_name)
        #  sql = "SHOW FULL FIELDS FROM #{quote_table_name(table_name)}"
        #  execute_and_free(sql, 'SCHEMA') do |result|
        #    result.collect { |field| field.first }
        #  end
        #end

        def column_names(table_name)
          columns(table_name).map(&:name)
        end

        # schema matchers
        def object_exists?(type, name, opts = {})
          send("#{type}_exists?", name, opts) if supported_objects.include? type.to_sym
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

        def index_exists?(name, opts = {})
          target = opts[:attr] ? opts[:attr][0] : nil
          raise "requires target object" unless target

          return false unless table_exists?(target) #mysql blows up when table doesn't exist
          return false unless name
          return true if indexes(name, nil, target).any?

          name           = name.to_s
          schema, target = name.split('.', 2)

          unless target # A table was provided without a schema
            target  = schema
            schema = nil
          end

          indexes(name, schema, target).any?
        end

        def proc_exists?(name, opts = {})
          return false unless name
          return true if procs(nil, nil, name).any?

          name = name.to_s
          schema, proc = name.split('.', 2)

          unless proc # A table was provided without a schema
            proc  = schema
            schema = nil
          end

          procs(name, schema, proc).any?
        end

        # queries
        def drop(type, name, opts = {})
          #binding.pry if type == 'proc'
          send("drop_#{type}", name, opts) if supported_objects.include? type.to_sym
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

        def drop_proc(name, opts = {})
          "DROP PROCEDURE IF EXISTS #{name}"
        end

        def drop_index(name, opts = {})
          target = opts[:attr].first if opts[:attr]
          raise "requires target object" unless target

          "DROP INDEX #{name} ON #{target}"
        end

        protected

        #def translate_exception(exception, message)
        #  exception
        #  # case error_number(exception)
        #  # when 1062
        #  #   RecordNotUnique.new(message, exception)
        #  # when 1452
        #  #   InvalidForeignKey.new(message, exception)
        #  # else
        #  #   super
        #  # end
        #end
      end
    end
  end
end

## encoding: utf-8
#module Skiima
#  module DbAdapters
#    class BaseMysqlAdapter < Base
#      attr_accessor :version
#
#      LOST_CONNECTION_ERROR_MESSAGES = [
#          "Server shutdown in progress",
#          "Broken pipe",
#          "Lost connection to MySQL server during query",
#          "MySQL server has gone away" ]
#
#      # FIXME: Make the first parameter more similar for the two adapters
#      def initialize(connection, logger, connection_options, config)
#        super(connection, logger)
#        @connection_options, @config = connection_options, config
#        @quoted_column_names, @quoted_table_names = {}, {}
#      end
#    end
#  end
#end