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

    it "allows options to be overridden" do
      #ski_too = Skiima.new()

      #test that config options are correctly overridden
    end
  end
end

