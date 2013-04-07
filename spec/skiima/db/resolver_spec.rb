# encoding: utf-8
require 'spec_helper'

describe Skiima::Db::Resolver do
  let(:db) { Skiima.read_db_yml(Skiima.full_database_path)[:test] }

  it "should force an adapter to be specified" do
    proc{ Skiima::Db::Resolver.new({}) }.must_raise(Skiima::AdapterNotSpecified)
  end

  it "should raise an error when there is not a valid adapter defined" do
    db[:adapter] = 'undefsql'
    proc{ Skiima::Db::Resolver.new(db) }.must_raise(LoadError)
  end

  it "should load the adapter class" do
    # bad test for ordering
    # proc { Skiima::DbAdapters::PostgresqlAdapter }.must_raise(NameError)

    Skiima::Db::Resolver.new(db)
    Skiima::Db::PostgresqlAdapter.must_be_instance_of Class
  end

  it "should set the adapter method" do
    Skiima::Db::Resolver.new(db).adapter_method.must_equal "postgresql_connection"
  end
end
