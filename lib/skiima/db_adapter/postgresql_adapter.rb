# encoding: utf-8
gem 'pg', '~> 0.11' # Make sure we're using pg high enough for PGResult#values
require 'pg'

module Skiima
  module DbAdapter
    class PostgresqlAdapter < Base
    	
    end
  end
end



        # def resolve_hash_connection(spec) # :nodoc:
        #   spec = spec.symbolize_keys

        #   raise(AdapterNotSpecified, "database configuration does not specify adapter") unless spec.key?(:adapter)

        #   begin
        #     require "active_record/connection_adapters/#{spec[:adapter]}_adapter"
        #   rescue LoadError => e
        #     raise LoadError, "Please install the #{spec[:adapter]} adapter: `gem install activerecord-#{spec[:adapter]}-adapter` (#{e.message})", e.backtrace
        #   end

        #   adapter_method = "#{spec[:adapter]}_connection"

        #   ConnectionSpecification.new(spec, adapter_method)
        # end