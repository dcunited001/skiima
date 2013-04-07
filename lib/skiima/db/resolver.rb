# encoding: utf-8
module Skiima
  module Db

    class Resolver
      extend Forwardable

      attr_accessor :db, :orm_module, :connector_klass
      attr_accessor :adapter

      delegate create_connector: :connector_klass

      def initialize(db_config)
        merge_db_defaults(db_config)
        adapter_specified?
        load_orm_module
        load_db_connector
      end

      private

      def merge_db_defaults(opts = {})
        @db = (db_defaults.merge(Skiima.symbolize_keys(opts)))
      end

      def db_defaults
        { orm: 'active_record' }
      end

      def adapter_specified?
        raise(AdapterNotSpecified, "database configuration does not specify adapter") unless db.key?(:adapter)
      end

      def load_db_connector
        #require "skiima/db/connector/#{db[:orm]}/postgresql_connector"
        require "skiima/db/connector/#{db[:orm]}/#{db[:adapter]}_connector"
        @connector_klass = get_db_connector_klass
      rescue => e
        raise LoadError, "Adapter does not exist for #{db[:orm]}: #{db[:adapter]} - (#{e.message})", e.backtrace
      end

      def load_orm_module
        require "skiima/db/connector/#{db[:orm]}"
      rescue => e
        raise LoadError, "Adapter Module does not exist for #{db[:orb]}: (#{e.message})", e.backtrace
      end

      def get_db_connector_klass
        #avoiding inflections
        #binding.pry if db[:adapter] == 'postgresql'
        @connector_klass =
          case (@orm_module = db[:orm])
          when 'active_record'
            case db[:adapter]
            when 'postgresql' then Skiima::Db::Connector::ActiveRecord::PostgresqlConnector
            when 'mysql'      then Skiima::Db::Connector::ActiveRecord::MysqlConnector
            when 'mysql2'     then Skiima::Db::Connector::ActiveRecord::Mysql2Connector
            end
          end
      end
    end

  end
end