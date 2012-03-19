# encoding: utf-8
require 'spec_helper'
require 'skiima/db_adapters/postgresql_adapter'

describe "Skiima::DbAdapters::PostgresqlAdapter" do
  let(:db) { Skiima.read_db_yaml(Skiima.full_database_path)[:test] }
  let(:pg_params) { [db[:host], db[:port], nil, nil, db[:database], db[:username], db[:password]] }
  let(:pg_adapter) { Skiima::DbAdapters::PostgresqlAdapter.new(nil, nil, pg_params, db) }

  describe "#initialize" do
    it 'should set params, attempt to connect, check the version, and get the timezone' do
      Skiima::DbAdapters::PostgresqlAdapter.any_instance.expects(:connect)
      Skiima::DbAdapters::PostgresqlAdapter.any_instance.expects(:postgresql_version).returns(80300)
      Skiima::DbAdapters::PostgresqlAdapter.any_instance.expects(:get_timezone).returns('UTC')

      pg_adapter.version.must_equal 80300
      pg_adapter.local_tz.must_equal 'UTC'
    end
  end
end
