# encoding: utf-8
require 'spec_helper'

describe "Mysql: " do
  let(:db_config) { {} }
  let(:ski) { Skiima.new(:mysql_test) }

  describe "Connection Setup: " do
    it "should get the version" do
      ensure_closed(ski) do |s|
        s.connector.version.must_be_instance_of Array
      end
    end

    it "can set a different encoding" do
      db_config.merge!(:encoding => 'utf-8')
      skip
    end
  end

  describe "Create/Drop Database: " do
    it "skips" do; skip; end
  end  

  describe "Create/Drop Tables: " do
    it 'should create and drop tables' do
      ensure_closed(ski) do |s|
        s.connector.table_exists?('test_table').must_equal false
        s.up(:test_table)
        s.connector.table_exists?('test_table').must_equal true
        s.down(:test_table)
        s.connector.table_exists?('test_table').must_equal false
      end
    end
  end

  describe "Create/Drop View: " do
    it 'should create and drop views' do
      ensure_closed(ski) do |s|
        s.connector.table_exists?('test_table').must_equal false
        s.connector.view_exists?('test_view').must_equal false

        s.up(:test_table, :test_view)
        s.connector.table_exists?('test_table').must_equal true
        s.connector.view_exists?('test_view').must_equal true

        s.down(:test_table, :test_view)
        s.connector.table_exists?('test_table').must_equal false
        s.connector.view_exists?('test_view').must_equal false
      end
    end
  end

  describe "Create/Drop Index: " do
    it 'should create and drop indexes' do
      ensure_closed(ski) do |s|
        s.connector.table_exists?('test_table').must_equal false
        s.connector.index_exists?('test_index', :attr => ['test_table']).must_equal false

        s.up(:test_table, :test_index)
        s.connector.table_exists?('test_table').must_equal true
        s.connector.index_exists?('test_index', :attr => ['test_table']).must_equal true

        s.down(:test_table, :test_index)
        s.connector.table_exists?('test_table').must_equal false
        s.connector.index_exists?('test_index', :attr => ['test_table']).must_equal false
      end
    end
  end

  describe "Column Names: " do
    it "should get a list of column names from a table" do
      ensure_closed(ski) do |s|
        s.connector.table_exists?('test_column_names').must_equal false
        s.up(:test_column_names)

        s.connector.column_names('test_column_names').must_include 'id', 'first_name'
        s.down(:test_column_names)
        # { s.connector.column_names('test_column_names') }.must_raise Error
      end
    end
  end

  describe "Create/Drop Procs: " do
    it "should create and drop procs, with or without a drop script" do
      ensure_closed(ski) do |s|
        s.connector.proc_exists?('test_proc').must_equal false
        s.connector.proc_exists?('test_proc_drop').must_equal false

        s.up(:test_proc)
        s.connector.proc_exists?('test_proc').must_equal true
        s.connector.proc_exists?('test_proc_drop').must_equal true

        s.down(:test_proc)
        s.connector.proc_exists?('test_proc').must_equal false
        s.connector.proc_exists?('test_proc_drop').must_equal false
      end
    end
  end
end

## encoding: utf-8
#require 'spec_helper'
#require 'skiima/db_adapters/mysql_adapter'
#
#describe "Skiima::DbAdapters::MysqlAdapter" do
#  let(:db) { Skiima.read_db_yml(Skiima.full_database_path)[:mysql_test] }
#  let(:mysql_params) { [db[:host], db[:username], db[:password], db[:database], db[:port], db[:socket], Mysql::CLIENT_MULTI_RESULTS] }
#  let(:mysql_adapter) { Skiima::DbAdapters::MysqlAdapter.new(Mysql.init, nil, mysql_params, db) }
#
#  describe "#initialize" do
#    before(:each) do
#      Mysql.any_instance.expects(:real_connect)
#      Skiima::DbAdapters::MysqlAdapter.any_instance.expects(:version)
#      Skiima::DbAdapters::MysqlAdapter.any_instance.expects(:configure_connection)
#    end
#
#    it 'should set connection options and config' do
#      mysql_adapter.instance_variable_get(:@connection_options).must_equal mysql_params
#      mysql_adapter.instance_variable_get(:@config).must_equal db
#    end
#
#    it 'should set ssl options if included' do
#      db.merge!({:sslkey => '123'})
#      Mysql.any_instance.expects(:ssl_set)
#
#      mysql_adapter
#    end
#
#    it 'should set encoding options if included' do
#      utf = 'utf-8'
#      db.merge!({:encoding => utf})
#      Mysql.any_instance.expects(:options).with(Mysql::SET_CHARSET_NAME, utf)
#
#      mysql_adapter
#    end
#  end
#
#end