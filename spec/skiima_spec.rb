# encoding: utf-8
require 'spec_helper'

describe Skiima do

  describe "Module Configuration Options" do
    it 'should set the proper module defaults' do
      Skiima.project_root.must_equal SKIIMA_ROOT
      Skiima.project_config_path.must_equal 'config'
      Skiima.config_file.must_equal 'skiima.yml'
      Skiima.database_config_file.must_equal 'database.yml'
      Skiima.skiima_path.must_equal 'db/skiima'
      Skiima.depends_file.must_equal 'depends.yml'
    end

    it 'does not override module defaults with skiima.yml options' do
      Skiima.logging_level.must_equal '3'
      Skiima.logging_out.must_equal '$stdout'
    end
  end

  describe "#message" do
    it 'should default to using the locale specified in config block' do
      Skiima.message('messages', 'create', 'start').must_equal "Creating objects for @class"
    end
  end
end



