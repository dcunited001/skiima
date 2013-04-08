require 'spec_helper'

include MiniTest::Spec::SharedExamples

shared_examples_for 'a skiima config' do
  describe Skiima::Config do
    it { subject.must_respond_to :config }
    it { subject.must_respond_to :config= }
    it { subject.must_respond_to :defaults }
  end
end