# encoding: utf-8
require 'spec_helper'

describe Skiima::Dependency::Reader do
  let(:groups) { [:init_test_db, :test_table] }
  let(:dependencies) { Skiima.read_dependencies_yml(Skiima.full_dependencies_path) }
  let(:adapter) { :postgresql }
  subject { Skiima::Dependency::Reader.new(dependencies, adapter) }

  describe "#initialize" do
    it 'should default the version to current' do
      subject.version.must_equal :current
    end
  end

  describe "#adapter" do
    it 'should return mysql if using a mysql/mysql2 adapter' do
      subject.adapter = 'mysql'
      subject.adapter.must_equal :mysql
      subject.adapter = 'mysql2'
      subject.adapter.must_equal :mysql
    end
  end

  describe "#get_load_order" do
    it 'should create a list of scripts under the groups, adapter and version specified' do
      scripts = subject.get_load_order(*groups)
      scripts.first.name.must_equal('skiima_test')
      scripts.last.name.must_equal('test_table')
    end

    it 'should return a blank list when the groups, adapter or version have no entries' do
      reader = Skiima::Dependency::Reader.new(dependencies, adapter)
      scripts = reader.get_load_order(:blank_group)
      scripts.count.must_equal 0

      reader = Skiima::Dependency::Reader.new(dependencies, :postgresql)
      scripts = reader.get_load_order(:only_pg)
      scripts.first.name.must_equal('only_pg')
    end
  end

  describe "Dependency Groups:" do
    let(:dependency_groups) { dependencies[:test_script_groups].map(&:to_sym) }

    it "should load the scripts for each dependency group, if the first level is an array" do
      scripts = subject.get_load_order(:test_script_groups)
      scripts.first.name.must_equal('test_table')
      scripts.last.name.must_equal('test_schema')
    end
  end
end