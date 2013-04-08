# encoding: utf-8
require 'skiima/db/helpers/mysql' unless defined? Skiima::Db::Helpers::Mysql
require 'skiima/db/connector/active_record/base_connector' unless defined? Skiima::Db::Connector::ActiveRecord::BaseConnector
require 'active_record/connection_adapters/mysql_adapter' unless defined? ActiveRecord::ConnectionAdapters::MysqlAdapter

module Skiima
  module Db
    module Connector
      module ActiveRecord

        class MysqlConnector < Skiima::Db::Connector::ActiveRecord::BaseConnector
          delegate [:tables, :indexes, :procs, :views, :schemas,
                    :drop, :drop_table, :drop_proc, :drop_view,
                    :drop_index, :drop_schema, :column_names,
                    :table_exists?, :index_exists?, :proc_exists?,
                    :view_exists?, :schema_exists?] => :adapter

          class << self
            delegate mysql_connection: :active_record_resolver_klass

            def create_adapter(config, logger, pool)
              case ::ActiveRecord::VERSION::MAJOR
                when 3,4 then send('mysql_connection', config)
              end
            end

            def helpers_module
              Skiima::Db::Helpers::Mysql
            end
          end
        end

      end
    end
  end
end