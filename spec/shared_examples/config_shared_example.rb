require 'spec_helper'

include MiniTest::Spec::SharedExamples

shared_examples_for 'a skiima config' do

  describe Skiima::Config do
    it { subject.must_respond_to :config }
    it { subject.must_respond_to :config= }
    it { subject.must_respond_to :defaults }
    it { subject.must_respond_to :full_scripts_path }
    it { subject.must_respond_to :full_database_path }
    it { subject.must_respond_to :full_dependencies_path }
    it { subject.must_respond_to :read_sql_file }
    it { subject.must_respond_to :read_db_yml }
    it { subject.must_respond_to :read_dependencies_yml }
    it { subject.must_respond_to :read_yml_or_throw }
    it { subject.must_respond_to :symbolize_keys }
    it { subject.must_respond_to :interpolate_sql }

    describe "#config" do
      it "returns @config"
      it "sets @config to the defaults, if nil"
    end

    describe "#config=" do
      it "sets @config"
      it "converts args to a Struct (?)"
    end

    describe "#symbolize_keys" do
      it "symbolizes keys for a hash"
    end

    describe "#interpolate_sql" do

    end
  end

end