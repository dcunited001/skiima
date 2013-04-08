# encoding: utf-8
require 'spec_helper'

describe Skiima::Db::Resolver do
  let(:yml) { Skiima.read_db_yml(Skiima.full_database_path) }
  let(:db) { yml[:postgresql_test] }
  subject { Skiima::Db::Resolver.new(db) }

  describe "#initialize" do
    it "should load the ORM module" do
      subject.orm_module.must_equal 'active_record'
    end

    it "should load the DB Connector Class" do
      subject.connector_klass.must_equal Skiima::Db::Connector::ActiveRecord::PostgresqlConnector
    end

    it "should merge db defaults with the db config" do
      subject.db[:orm].must_equal 'active_record'
      subject.db[:adapter].must_equal 'postgresql'
    end
  end

  describe "AdapterNotSpecified" do
    let(:db) { Hash.new }
    it "should force an adapter to be specified" do
      proc{ subject }.must_raise(Skiima::AdapterNotSpecified)
    end
  end

  describe "LoadError: ORM not defined" do
    let(:db) { yml[:postgresql_test].merge(adapter: 'undef') }
    it "should raise an error when there is not a valid adapter defined" do
      proc{ subject }.must_raise(LoadError)
    end
  end

  describe "LoadError: Adapter not defined" do
    let(:db) { yml[:postgresql_test].merge(orm: 'undef') }
    it "should raise an error when there is not a valid orm defined" do
      proc{ subject }.must_raise(LoadError)
    end
  end

end

  # test this?
  #it "should load the adapter class" do
  #  # bad test for ordering
  #  # proc { Skiima::DbAdapters::PostgresqlAdapter }.must_raise(NameError)
  #
  #  Skiima::Db::Resolver.new(db)
  #  Skiima::Db::PostgresqlAdapter.must_be_instance_of Class
  #end