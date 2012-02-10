# encoding: utf-8
require 'spec_helper'

describe Skiima::Dependency::Reader do
  let(:depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/depends.yml') }
  subject { Skiima::Dependency::Sequential.new(:depends_file => depends_file) }

  describe "#get_load_order" do
    it "takes a list of sql groups" do
      
    end

    it "returns a list of sql script objects in the proper order" do
       
    end

    it "throws a SqlGroupNotFound error when a group is mis-spelled or missing" do
      
    end

    it "throws a SqlObjectNotFound" do
      
    end
  end
end
