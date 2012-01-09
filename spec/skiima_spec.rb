# encoding: utf-8
require 'spec_helper'

describe Skiima do

  describe "Module Configuration Options" do
    it 'should set the proper module defaults' do

      #expected config paths
      project_config_path = File.join(SKIIMA_ROOT, 'config')
      skiima_yml_file = File.join(project_config_path, 'skiima.yml')
      db_config_file = File.join(project_config_path, 'database.yml')

      #expected depends config paths
      skiima_path = File.join(SKIIMA_ROOT, 'db/skiima')
      depends_file = File.join(skiima_path, 'depends.yml')

      #expected locale config paths
      locale_path = File.join(SKIIMA_ROOT, 'config')
      locale_file = File.join(locale_path, 'skiima.en.yml')

      Skiima.project_root.must_equal SKIIMA_ROOT
      Skiima.project_config_path.must_equal project_config_path
      Skiima.config_file.must_equal skiima_yml_file
      Skiima.database_config_file.must_equal db_config_file

      Skiima.skiima_path.must_equal skiima_path
      Skiima.depends_file.must_equal depends_file

      Skiima.locale_path.must_equal locale_path
      Skiima.locale_file.must_equal locale_file
    end
  end
end

