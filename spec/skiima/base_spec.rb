# encoding: utf-8
require 'spec_helper'

describe Skiima::Base do
  subject { Skiima::Base }

  before do
    ski = Skiima.new
  end

  describe "Config: " do
    it "inherits module configuration" do
      #assert that config options are the same as module defaults
    end

    it "allows options to be overridden" do
      #ski_too = Skiima.new()

      #test that config options are correctly overridden
    end
  end
end

