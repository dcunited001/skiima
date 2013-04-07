# encoding: utf-8
require 'spec_helper'
require 'helpers/postgresql_spec_helper'

describe "Postgresql: " do
  let(:ski) { Skiima.new(:postgresql_test) }

  describe "Connection Setup: " do
    it "should get the version" do
      ensure_closed(ski) do |s|
        s.connector.version.must_be_instance_of Fixnum
      end
    end

    it "should get the timezone" do
      ensure_closed(ski) do |s|
        s.connector.local_tz.must_be_instance_of String
      end
    end
  end

  describe "Create/Drop Databases: " do
    it "should create and drop databases" do
      skip # permissions
    end
  end

  describe "Create/Drop Table: " do
    it "should create and drop a table" do
      ensure_closed(ski) do |skiima|
        within_transaction(skiima) do |s|
          s.connector.table_exists?('test_table').must_equal false
          s.up(:test_table)
          s.connector.table_exists?('test_table').must_equal true
          s.down(:test_table)
          s.connector.table_exists?('test_table').must_equal false
        end
      end
    end

    it "should handle multiple schemas in a database" do
      skip # pending
    end
  end

  describe "Create/Drop Schema: " do
    #schema's cant be rolled back
    it "should create and drop schemas" do
      ensure_closed(ski) do |s|
        s.connector.schema_exists?('test_schema').must_equal false
        s.up(:test_schema)
        s.connector.schema_exists?('test_schema').must_equal true
        s.down(:test_schema)
        s.connector.schema_exists?('test_schema').must_equal false
      end
    end
  end

  describe "Create/Drop View: " do
    it "should create and drop views" do
      ensure_closed(ski) do |skiima|
        within_transaction(skiima) do |s|
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
  end

  describe "Create/Drop Rules: " do
    it "should create and drop rules" do
      ensure_closed(ski) do |skiima|
        within_transaction(skiima) do |s|
          s.connector.table_exists?('test_table').must_equal false
          s.connector.view_exists?('test_view').must_equal false
          s.connector.rule_exists?('test_rule', :attr => ['test_view']).must_equal false

          s.up(:test_table, :test_view, :test_rule)
          s.connector.table_exists?('test_table').must_equal true
          s.connector.view_exists?('test_view').must_equal true
          s.connector.rule_exists?('test_rule', :attr => ['test_view']).must_equal true

          s.down(:test_table, :test_view, :test_rule)
          s.connector.table_exists?('test_table').must_equal false
          s.connector.view_exists?('test_view').must_equal false
          s.connector.rule_exists?('test_rule', :attr => ['test_view']).must_equal false
        end
      end
    end
  end

  describe "Create/Drop Indexes: " do
    it "should create and drop indexes" do
      ensure_closed(ski) do |skiima|
        within_transaction(skiima) do |s|
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
  end

  describe "Create/Drop Users: " do

  end

  describe "Column Names: " do
    it "should get a list of column names from a table" do
      ensure_closed(ski) do |skiima|
        within_transaction(skiima) do |s|
          s.connector.table_exists?('test_column_names').must_equal false
          s.up(:test_column_names)

          s.connector.column_names('test_column_names').must_include 'id', 'first_name'
          s.down(:test_column_names)
          # { s.connection.column_names('test_column_names') }.must_raise Error
        end
      end
    end
  end
end

