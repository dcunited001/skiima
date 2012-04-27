# encoding: utf-8
require 'spec_helper'

describe "Mysql: " do
  let(:db_config) { {} }
  let(:ski) { Skiima.new(:mysql_test) }

  describe "Connection Setup: " do
    it "should get the version" do
      ensure_closed(ski) do |s|
        s.connection.version.must_be_instance_of Array
      end
    end

    it "can set a different encoding" do
      db_config.merge!(:encoding => 'utf-8')
      skip
    end
  end

  describe "Create/Drop Database: " do

  end  

  describe "Create/Drop Tables: " do
    it 'should create and drop tables' do
      ensure_closed(ski) do |s|
        s.connection.table_exists?('test_table').must_equal false
        s.up(:test_table)
        s.connection.table_exists?('test_table').must_equal true
        s.down(:test_table)
        s.connection.table_exists?('test_table').must_equal false
      end
    end
  end

  describe "Create/Drop View: " do
    it 'should create and drop views' do
      ensure_closed(ski) do |s|
        s.connection.table_exists?('test_table').must_equal false
        s.connection.view_exists?('test_view').must_equal false

        s.up(:test_table, :test_view)
        s.connection.table_exists?('test_table').must_equal true
        s.connection.view_exists?('test_view').must_equal true

        s.down(:test_table, :test_view)
        s.connection.table_exists?('test_table').must_equal false
        s.connection.view_exists?('test_view').must_equal false
      end
    end
  end

  describe "Create/Drop Index: " do
    it 'should create and drop indexes' do
      ensure_closed(ski) do |s|
        s.connection.table_exists?('test_table').must_equal false
        s.connection.index_exists?('test_index', :attr => ['test_table']).must_equal false

        s.up(:test_table, :test_index)
        s.connection.table_exists?('test_table').must_equal true
        s.connection.index_exists?('test_index', :attr => ['test_table']).must_equal true

        s.down(:test_table, :test_index)
        s.connection.table_exists?('test_table').must_equal false
        s.connection.index_exists?('test_index', :attr => ['test_table']).must_equal false
      end
    end
  end

  describe "Column Names: " do
    it "should get a list of column names from a table" do
      ensure_closed(ski) do |s|
        s.connection.table_exists?('test_column_names').must_equal false
        s.up(:test_column_names)

        s.connection.column_names('test_column_names').must_include 'id', 'first_name'
        s.down(:test_column_names)
        # { s.connection.column_names('test_column_names') }.must_raise Error
      end
    end
  end

  describe "Create/Drop Procs: " do
    it "should create and drop procs, with or without a drop script" do
      ensure_closed(ski) do |s|
        s.connection.proc_exists?('test_proc').must_equal false
        s.connection.proc_exists?('test_proc_drop').must_equal false

        s.up(:test_proc)
        s.connection.proc_exists?('test_proc').must_equal true
        s.connection.proc_exists?('test_proc_drop').must_equal true

        s.down(:test_proc)
        s.connection.proc_exists?('test_proc').must_equal false
        s.connection.proc_exists?('test_proc_drop').must_equal false
      end
    end
  end
end