# encoding: utf-8
require 'spec_helper'

describe Skiima::Dependency::Script do
  let(:group) { 'test_view' }
  let(:adapter) { 'postgresql' }
  let(:version) { 'current' }
  let(:scriptname) { 'view.test_view' }
  subject { Skiima::Dependency::Script.new(group, adapter, version, scriptname) }

  describe '#initialize' do
    it 'should split the object type and name from the scriptname' do
      subject.type.must_equal 'view'
      subject.name.must_equal 'test_view'
    end
  end

  describe "#target" do
    it 'should return the target object for rules, triggers, etc' do
      rule_script = Skiima::Dependency::Script.new(group, adapter, version, 'rule.test_rule.test_view')
      rule_script.attr[0].must_equal 'test_view'
    end
  end

  describe "#adapter" do
    it 'should return mysql if using a mysql/mysql2 adapter' do
      subject.adapter = 'mysql'
      subject.adapter.must_equal 'mysql'
      subject.adapter = 'mysql2'
      subject.adapter.must_equal 'mysql'
    end
  end

  describe "#filename" do
    it 'should return the filename' do
      subject.filename.must_equal "#{subject.type}.#{subject.name}.#{adapter}.#{version}.sql"
    end
  end

  describe "#down_filename" do
    it 'returns the filename to look for'
  end

  describe "down_script?" do
    it 'should return true when the file exists'
    it 'should return false when a script cant be found'
  end

  describe '#read_content' do
    it 'should store file content' do
      subject.read_content(:up, Skiima.full_scripts_path).must_include "test_view"
    end
  end

  describe '#interpolate_sql' do
    it 'should replace vars with their substituions' do
      interpolation_vars = {:database => 'db_name', :schema => 'schema_name', :table => 'table_name'}
      subject.content = 'SELECT * FROM &database.&schema.&table'
      subject.interpolate_sql('&', interpolation_vars)
      subject.sql.must_equal "SELECT * FROM db_name.schema_name.table_name"
    end
  end
end

describe Skiima::Dependency::Reader do
  let(:groups) { [:init_test_db, :test_table] }
  let(:depends) { Skiima.read_depends_yaml(Skiima.full_depends_path) }
  let(:adapter) { :postgresql }
  subject { Skiima::Dependency::Reader.new(depends, adapter) }

  describe "#initialize" do
    it 'should default the version to current' do
      subject.version.must_equal :current
    end
  end

  describe "#get_load_order" do
    it 'should create a list of scripts under the groups, adapter and version specified' do
      scripts = subject.get_load_order(*groups)
      scripts.first.name.must_equal('skiima_test')
      scripts.last.name.must_equal('test_table')
    end
    
    it 'should return a blank list when the groups, adapter or version have no entries' do
      reader = Skiima::Dependency::Reader.new(depends, adapter)
      scripts = reader.get_load_order(:blank_group)
      scripts.count.must_equal 0

      reader = Skiima::Dependency::Reader.new(depends, :postgresql)
      scripts = reader.get_load_order(:only_pg)
      scripts.first.name.must_equal('only_pg')
    end
  end
end