# encoding: utf-8
require 'spec_helper'

describe Skiima do
  describe "Module Configuration Options" do
    it "should set the proper module defaults" do
      Skiima.root_path.must_equal SKIIMA_ROOT
      Skiima.config_path.must_equal 'config'
      Skiima.database_yaml.must_equal 'database.yml'
      Skiima.scripts_path.must_equal 'db/skiima'
      Skiima.depends_yaml.must_equal 'depends.yml'
    end
  end

  describe "#message" do
    it "should default to using the locale specified in config block" do
      Skiima.msg('messages', 'create', 'start').must_equal "Creating objects for @class"
    end
  end

  # describe "implementation" do
  #   let(:groups) { %w(friend team_member) }
  #                                                                   {}
  #   it "should take a list of strings and run their SQL up scripts for them" do
  #     Skiima.expects(:new).with({}).returns(base = Skiima::Base.new)
  #     base.expects(:up).with(*groups)
  #     Skiima.up('friend', 'team_member')
  #   end

  #   it "should take a list of strings and run their SQL down scripts for them" do
  #     Skiima.expects(:new).with({}).returns(base = Skiima::Base.new)
  #     base.expects(:down).with(*groups)
  #     Skiima.down('friend', 'team_member')
  #   end

  #   describe "Errors: " do
  #     it "should return a group not found error when a class/string can't be found in depends.yml" do

  #     end
  #   end
  # end
end

describe Skiima::Loader do
  subject { Skiima::Loader.new(:test) }

  describe "#config" do
    before(:each) { Skiima::Loader.any_instance.expects(:make_connection).returns(true) }
  	let(:config_path) { 'config' }
  	let(:db_yaml) { 'database.yml' }

  	it "inherits module defaults" do
      subject.root_path.must_equal SKIIMA_ROOT
      subject.config_path.must_equal config_path
      subject.database_yaml.must_equal db_yaml
    end

    it "overrides module defaults with options hash" do
      ski_too = Skiima::Loader.new(:test, :logging_out => 'STDERR')
      ski_too.logging_out.must_equal 'STDERR'
    end
  end

  describe "Logger: " do
    before(:each) { Skiima::Loader.any_instance.expects(:make_connection).returns(true) }

    it "creates a logger with the correct options" do
      subject.logger.class.must_equal ::Logger
    end
  end

  # describe "Implementation: " do
  #   let(:groups) { groups = %w(friend team_member) }
  #   let(:scripts) do 
  #     scripts = %w(view_friends rule_view_friends_delete rule_view_friends_insert).map {|s| Skiima::Dependency::Script.new('friend', s)} 
  #   end

  #   it "should take a list of strings and run their SQL up scripts for them" do
  #     subject.expects(:execute_dependency_reader).with(groups).returns(scripts)
  #     subject.expects(:execute_loader).with(:up, scripts).returns('Great Success!!')
  #     subject.up(*groups)
  #   end

  #   it "should take a list of strings and run their SQL down scripts for them" do
  #     subject.expects(:execute_dependency_reader).with(groups).returns(scripts)
  #     subject.expects(:execute_loader).with(:down, scripts).returns('Great Success!!')
  #     subject.down('friend', 'team_member')
  #   end

  #   describe "Errors: " do
  #     it "should return a group not found error when a class/string can't be found in depends.yml" do
  #       proc { subject.up('friendz', 'team_memberz') }.must_raise(Skiima::SqlGroupNotFound)
  #     end
  #   end
  # end
end

