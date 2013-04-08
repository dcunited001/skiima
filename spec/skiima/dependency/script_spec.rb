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

  describe "#filename" do
    it 'should return the filename' do
      subject.filename.must_equal "#{subject.type}.#{subject.name}.#{adapter}.#{version}.sql"
    end
  end

  describe "#down_filename" do
    it 'returns the filename to look for' do
      subject.down_filename.must_equal "#{subject.type}.#{subject.name}.#{adapter}.#{version}.drop.sql"
    end
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