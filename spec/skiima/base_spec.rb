# encoding: utf-8
require 'spec_helper'

describe Skiima::Base do
  subject { Skiima::Base.new }

  describe "#read_config_file" do
    let(:config_file) { File.join(SKIIMA_ROOT, 'config/skiima.yml') }
    let(:empty_config_file) { File.join(SKIIMA_ROOT, 'config/empty_skiima.yml') }
    let(:no_config_file) { File.join(SKIIMA_ROOT, 'db/skiima/not_there.yml') }

    it 'sets the config options' do
      config = subject.send(:read_config, config_file)
      config[:load_order].must_equal 'Sequential'
      config[:logging_out].must_equal 'STDOUT'
      config[:logging_level].wont_be_nil
    end

    it 'returns an empty hash if config file is empty' do
      empty_config = subject.send(:read_config, empty_config_file)
      empty_config.must_equal({})
    end

    it 'raises exception if config file can not be found' do
      proc { subject.send(:read_config, no_config_file) }.must_raise(Skiima::MissingFileException)
    end
  end

  describe "Config: " do
    let(:project_config_path) { File.join(SKIIMA_ROOT, 'config') }
    let(:skiima_yml_file) { File.join(project_config_path, 'skiima.yml') }
    let(:db_config_file) { File.join(project_config_path, 'database.yml') }

    let(:skiima_path) { File.join(SKIIMA_ROOT, 'db/skiima') }
    let(:depends_file) { File.join(skiima_path, 'depends.yml') }

    it "inherits module defaults" do
      subject.project_root.must_equal SKIIMA_ROOT
      subject.project_config_path.must_equal project_config_path
      subject.skiima_path.must_equal skiima_path
    end

    it "overrides module defaults with options hash" do
      ski_too = Skiima::Base.new(:database_config_file => 'postgresql.yml')
      ski_too.database_config_file.must_equal File.join(SKIIMA_ROOT, 'config', 'postgresql.yml')
    end

    it "overrides module defaults with skiima.yml" do
      subject.logger.level.must_equal ::Logger::DEBUG
    end
  end

  describe "Logger: " do
    it "creates a logger with the correct options" do
      subject.logger.class.must_equal ::Logger
    end
  end

  describe "Implementation: " do
    let(:groups) { groups = %w(friend team_member) }
    let(:scripts) do 
      scripts = %w(view_friends rule_view_friends_delete rule_view_friends_insert).map {|s| Skiima::Dependency::Script.new('friend', s)} 
    end

    it "should take a list of strings and run their SQL up scripts for them" do
      subject.expects(:execute_dependency_reader).with(groups).returns(scripts)
      subject.expects(:execute_loader).with(:up, scripts).returns('Great Success!!')
      subject.up(*groups)
    end

    it "should take a list of strings and run their SQL down scripts for them" do
      subject.expects(:execute_dependency_reader).with(groups).returns(scripts)
      subject.expects(:execute_loader).with(:down, scripts).returns('Great Success!!')
      subject.down('friend', 'team_member')
    end

    describe "Errors: " do
      it "should return a group not found error when a class/string can't be found in depends.yml" do
        proc { subject.up('friendz', 'team_memberz') }.must_raise(Skiima::SqlGroupNotFound)
      end
    end
  end
end
