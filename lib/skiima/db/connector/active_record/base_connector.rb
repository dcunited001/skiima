# encoding: utf-8
require 'active_record' unless defined? ActiveRecord
require 'active_support' unless defined? ActiveSupport

module Skiima
  module Db
    module Connector
      module ActiveRecord

        class BaseConnector < Skiima::Db::Connector::Base
          delegate [:version, :execute,
                    :adapter_name, :supported_objects,
                    :supports_ddl_transactions?,
                    :drop, :active?, :object_exists?,
                    :reconnect!, :disconnect!, :close,
                    :reset!, :verify!, :raw_connection,
                    :begin_db_transaction, :rollback_db_transaction] => :adapter

          #alias_method :connection, :raw_connection

          class << self
            def active_record_resolver_klass
              case ::ActiveRecord::VERSION::MAJOR
                when 3,4 then ::ActiveRecord::Base
              end
            end
          end
        end

      end
    end
  end
end