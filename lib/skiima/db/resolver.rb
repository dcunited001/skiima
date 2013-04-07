# encoding: utf-8
module Skiima
  module Db

    class Resolver
      attr_accessor :db, :orm, :adapter, :adapter_method

      def initialize(db_config)
        merge_db_defaults(db_config)
        adapter_specified?
        set_adapter_method
        load_orm_adapter
        load_db_connector
      end

      def create_connection
        @adapter.send(adapter_method)  #opts?
      end

      private

      def set_adapter_method
        @adapter_method = "#{db[:adapter]}_adapter"
      end

      def merge_db_defaults(opts = {})
        @db = (db_defaults.merge(Skiima.symbolize_keys(opts)))
      end

      def db_defaults
        { orm: :active_record }
      end

      def adapter_specified?
        raise(AdapterNotSpecified, "database configuration does not specify adapter") unless db.key?(:adapter)
      end

      def load_db_connector
        @adapter = get_db_connector
        require "skiima/db/connector/#{db[:orm]}/#{db[:adapter]}_connector"
      rescue => e
        raise LoadError, "Adapter does not exist for #{db[:orb]}: #{db[:adapter]} - (#{e.message})", e.backtrace
      end

      def load_orm_adapter
        require "skiima/db/connector/#{db[:orm]}"
        @orm = get_orm_adapter
      rescue => e
        raise LoadError, "Adapter does not exist for #{db[:orb]}: (#{e.message})", e.backtrace
      end

      def get_orm_adapter
        case db[:orm]
          when :active_record then Skiima::Db::Connector::ActiveRecord
          # :datamapper
          # :sequel
        end
      end

      def get_db_connector
        case db[:adapter]
          when :postgresql then orm::PostgresqlConnector
          when :mysql then orm::MysqlConnector
          #when :mysql2 then orm::Mysql2Connector
        end
      end
    end

  end
end