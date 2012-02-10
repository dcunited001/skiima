# encoding: utf-8
require 'spec_helper'

describe Skiima do

  describe "Module Configuration Options" do
    it "should set the proper module defaults" do
      Skiima.project_root.must_equal SKIIMA_ROOT
      Skiima.project_config_path.must_equal 'config'
      Skiima.config_file.must_equal 'skiima.yml'
      Skiima.database_config_file.must_equal 'database.yml'
      Skiima.skiima_path.must_equal 'db/skiima'
      Skiima.depends_file.must_equal 'depends.yml'
    end

    it "does not override module defaults with skiima.yml options" do
      Skiima.logging_level.must_equal '3'
      Skiima.logging_out.must_equal '$stdout'
    end
  end

  describe "#message" do
    it "should default to using the locale specified in config block" do
      Skiima.message('messages', 'create', 'start').must_equal "Creating objects for @class"
    end
  end

  describe "implementation" do
    let(:groups) { %w(friend team_member) }
                                                                    {}
    it "should take a list of strings and run their SQL up scripts for them" do
      Skiima.expects(:new).with({}).returns(base = Skiima::Base.new)
      base.expects(:up).with(*groups)
      Skiima.up('friend', 'team_member')
    end

    it "should take a list of strings and run their SQL down scripts for them" do
      Skiima.expects(:new).with({}).returns(base = Skiima::Base.new)
      base.expects(:down).with(*groups)
      Skiima.down('friend', 'team_member')
    end

    describe "Errors: " do
      it "should return a group not found error when a class/string can't be found in depends.yml" do

      end
    end
  end

  describe "#supported_adapters" do
    it "can return a list of supported sql adapters" do
      
    end
  end

  describe "#supported_object_classes" do
    it "can return a list of supported object types per adapter" do

    end
  end

  describe "#supported_depedency_readers" do

  end
end

