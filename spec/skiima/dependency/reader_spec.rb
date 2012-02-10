# encoding: utf-8
require 'spec_helper'

describe Skiima::Dependency::Reader do
  let(:depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/depends.yml') }
  subject { Skiima::Dependency::Reader.new(:depends_file => depends_file) }

  describe "#read_depends_file" do
    let(:empty_depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/empty_depends.yml') }
    let(:no_depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/not_there.yml') }

    it "sets an ordered array for each set of sql objects" do
      depends_set = subject.read_depends_file(depends_file)
      depends_set['friends'].must_include('view_friends', 'rule_view_friends_delete')
    end

    it "sets an empty array if there are no sql objects for a set" do
      empty_depends_set = subject.read_depends_file(depends_file)
      empty_depends_set['team_members'].must_be_nil
    end

    it "returns an empty hash if there are no sets of sql objects" do
      empty_depends = subject.read_depends_file(empty_depends_file)
      empty_depends.must_equal({})
    end

    it "raises exception if depends file can not be found" do
      proc { subject.read_depends_file(no_depends_file) }.must_raise(Skiima::MissingFileException)
    end
  end

end

