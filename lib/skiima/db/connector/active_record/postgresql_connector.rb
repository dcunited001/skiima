# encoding: utf-8
require 'skiima/db/helpers/postgresql' unless defined? Skiima::Db::Helpers::Postgresql
require 'skiima/db/connector/active_record/base_connector' unless defined? Skiima::Db::Connector::ActiveRecord::BaseConnector
require 'active_record/connection_adapters/postgresql_adapter' unless defined? ActiveRecord::ConnectionAdapters::PostreSQLAdapter

module Skiima
  module Db
    module Connector
      module ActiveRecord

        class PostgresqlConnector < Skiima::Db::Connector::ActiveRecord::BaseConnector
          delegate [:local_tz, :column_names, :check_psql_version,
                    :table_exists?, :index_exists?, :rule_exists?,
                    :view_exists?, :schema_exists?] => :adapter

          def initialize(adapter, logger, config = {})
            super
            check_psql_version
          end

          class << self
            delegate postgresql_connection: :active_record_resolver_klass

            def create_adapter(config, logger, pool)
              case ::ActiveRecord::VERSION::MAJOR
                when 3,4 then send('postgresql_connection', config)
              end
            end

            def helpers_module
              Skiima::Db::Helpers::Postgresql
            end
          end

        end
      end
    end
  end
end
