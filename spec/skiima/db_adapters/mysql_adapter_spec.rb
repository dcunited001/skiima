# encoding: utf-8
require 'spec_helper'
require 'skiima/db_adapters/mysql_adapter'

describe "Skiima::DbAdapters::MysqlAdapter" do
  let(:db) { Skiima.read_db_yaml(Skiima.full_database_path)[:mysql_test] }
  let(:mysql_params) { [db[:host], db[:username], db[:password], db[:database], db[:port], db[:socket], Mysql::CLIENT_MULTI_RESULTS] }
  let(:mysql_adapter) { Skiima::DbAdapters::MysqlAdapter.new(Mysql.init, nil, mysql_params, db) }

  describe "#initialize" do
    before(:each) do
      Mysql.any_instance.expects(:real_connect)
      Skiima::DbAdapters::MysqlAdapter.any_instance.expects(:version)
      Skiima::DbAdapters::MysqlAdapter.any_instance.expects(:configure_connection)
    end 

    it 'should set connection options and config' do
      mysql_adapter.instance_variable_get(:@connection_options).must_equal mysql_params
      mysql_adapter.instance_variable_get(:@config).must_equal db
    end

    it 'should set ssl options if included' do
      db.merge!({:sslkey => '123'})
      Mysql.any_instance.expects(:ssl_set)

      mysql_adapter
    end

    it 'should set encoding options if included' do
      utf = 'utf-8'
      db.merge!({:encoding => utf})
      Mysql.any_instance.expects(:options).with(Mysql::SET_CHARSET_NAME, utf)

      mysql_adapter
    end
  end
  
end