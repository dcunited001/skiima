# encoding: utf-8
require 'spec_helper'

describe Skiima do

  describe "Module Configuration Options" do
    it 'should set the proper module defaults' do
      project_config_path = File.join(SKIIMA_ROOT, 'config')
      skiima_yml_file = File.join(project_config_path, 'skiima.yml')
      db_config_file = File.join(project_config_path, 'database.yml')

      skiima_path = File.join(SKIIMA_ROOT, 'db/skiima')
      depends_file = File.join(skiima_path, 'depends.yml')

      Skiima.project_root.must_equal SKIIMA_ROOT
      Skiima.project_config_path.must_equal project_config_path
      Skiima.config_file.must_equal skiima_yml_file
      Skiima.database_config_file.must_equal db_config_file

      Skiima.skiima_path.must_equal skiima_path
      Skiima.depends_file.must_equal depends_file
    end

    it 'does not override module defaults with skiima.yml options' do
      Skiima.logging_level.must_equal '3'
    end

  end

  describe "#message" do
    it 'should default to using the locale specified in config block' do
      Skiima.message('messages', 'create', 'start').must_equal "Creating objects for @class"
    end
  end
end



