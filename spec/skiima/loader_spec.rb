# encoding: utf-8
require 'spec_helper'

describe Skiima::Loader do
  subject { Skiima::Loader.new(:postgresql_test) }

  it_behaves_like "a skiima config"

  it { subject.must_respond_to :env }
  it { subject.must_respond_to :db }
  it { subject.must_respond_to :connection }
  it { subject.must_respond_to :scripts }
  it { subject.must_respond_to :logger }

  describe "#default" do
    it "must return a config struct with the defaults set for this Skiima::Loader"
    it "must return a config struct with the defaults descended from Skiima module" do
      #Skiima.stub(:defaults)
    end
  end

  describe "#config" do

  end

  describe "#new" do
    it "must set vars if they are passed in"
  end

  describe "#up" do

  end

  describe "#down" do

  end

  describe "#interpolation_vars" do

  end

  describe "#log_message" do

  end

  describe "#make_connection" do

  end


  describe "#config" do
    before(:each) { Skiima::Loader.any_instance.expects(:create_connector).returns(true) }
    let(:config_path) { 'config' }
    let(:db_yml) { 'database.yml' }

    it "inherits module defaults" do
      subject.root_path.must_equal SKIIMA_ROOT
      subject.config_path.must_equal config_path
      subject.database_yml.must_equal db_yml
    end

    it "overrides module defaults with options hash" do
      ski_too = Skiima::Loader.new(:test, :logging_out => 'STDERR')
      ski_too.logging_out.must_equal 'STDERR'
    end
  end

  #describe "Logger: " do
  #  before(:each) { Skiima::Loader.any_instance.expects(:create_connector).returns(true) }
  #
  #  it "creates a logger with the correct options" do
  #    #subject.logger.class.must_equal ::Logger
  #    subject.logger.class.must_equal Skiima::Logger
  #  end
  #end

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
  #     it "should return a group not found error when a class/string can't be found in dependencies.yml" do
  #       proc { subject.up('friendz', 'team_memberz') }.must_raise(Skiima::SqlGroupNotFound)
  #     end
  #   end
  # end
end

