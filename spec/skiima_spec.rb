# encoding: utf-8
require 'spec_helper'

describe Skiima do
  describe "Module Configuration Options" do
    it "should set the proper module defaults" do
      Skiima.root_path.must_equal SKIIMA_ROOT
      Skiima.config_path.must_equal 'config'
      Skiima.database_yml.must_equal 'database.yml'
      Skiima.scripts_path.must_equal 'db/skiima'
      Skiima.depends_yml.must_equal 'depends.yml'
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
