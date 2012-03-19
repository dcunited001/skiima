# encoding: utf-8
require 'spec_helper'

describe Skiima::DbAdapters::Resolver do
  let(:db) { Skiima.read_db_yaml(Skiima.full_database_path)[:test] }

  it "should force an adapter to be specified" do
    proc{ Skiima::DbAdapters::Resolver.new({}) }.must_raise(Skiima::AdapterNotSpecified)
  end

  it "should raise an error when there is not a valid adapter defined" do
    db[:adapter] = 'undefsql'
    proc{ Skiima::DbAdapters::Resolver.new(db) }.must_raise(LoadError)
  end

  it "should load the adapter class" do
    # bad test for ordering
    # proc { Skiima::DbAdapters::PostgresqlAdapter }.must_raise(NameError)

    Skiima::DbAdapters::Resolver.new(db)
    Skiima::DbAdapters::PostgresqlAdapter.must_be_instance_of Class
  end

  it "should set the adapter method" do
    Skiima::DbAdapters::Resolver.new(db).adapter_method.must_equal "postgresql_connection"
  end
end

describe Skiima::DbAdapters::Base do
  
end