# encoding: utf-8
# encoding: utf-8
require 'skiima/db/helpers/mysql' unless defined? Skiima::Db::Helpers::Mysql
require 'skiima/db/connector/active_record/base_connector' unless defined? Skiima::Db::Connector::ActiveRecord::BaseConnector
require 'active_record/connection_adapters/mysql2_adapter' unless defined? ActiveRecord::ConnectionAdapters::Mysql2Adapter


module Skiima
  module Db
    module Connector
      module ActiveRecord
        class Mysql2Connector < Skiima::Db::Connector::ActiveRecord::BaseConnector
          delegate [:table_exists?, :index_exists?, :proc_exists?,
                    :view_exists?, :schema_exists?] => :adapter

          class << self
            delegate mysql2_connection: :active_record_resolver_klass

            def create_adapter(config, logger, pool)
              case ::ActiveRecord::VERSION::MAJOR
                when 3,4 then send('mysql2_connection', config)
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