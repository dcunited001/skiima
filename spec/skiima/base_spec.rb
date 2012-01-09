# encoding: utf-8
require 'spec_helper'

describe Skiima::Base do
  subject { Skiima::Base.new }

  describe "Config: " do
    it "inherits module configuration" do
      project_config_path = File.join(SKIIMA_ROOT, 'config')
      skiima_path = File.join(SKIIMA_ROOT, 'db/skiima')

      subject.project_root.must_equal SKIIMA_ROOT
      subject.project_config_path.must_equal project_config_path
      subject.skiima_path.must_equal skiima_path
    end

    it "allows module options to be overridden per instance" do
      ski_too = Skiima.new(
        :database_config_file => 'postgresql.yml',
        :locale => :jp)

      ski_too.database_config_file.must_equal File.join(SKIIMA_ROOT, 'config', 'postgresql.yml')
      ski_too.locale_file.must_equal File.join(SKIIMA_ROOT, 'config', 'skiima.jp.yml')
    end
  end
end

