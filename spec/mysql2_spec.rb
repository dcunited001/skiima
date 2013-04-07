# encoding: utf-8
require 'spec_helper'

describe "Mysql2: " do
  let(:db_config) { {} }
  let(:ski) { Skiima.new(:mysql2_test) }

  describe "connector Setup: " do
    it "should get the version" do
      ensure_closed(ski) do |s|
        s.connector.version.must_be_instance_of Array
      end
    end

    it "can set a different encoding" do
      db_config.merge!(:encoding => 'utf-8')
      skip
    end

    it "can set a different timezone" do
      skip
    end
  end

  describe "Create/Drop Database: " do
    
  end  

  describe "Create/Drop Tables: " do
    it 'should be able to create and drop tables' do
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
    it 'should be able to create and drop views' do
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
end
