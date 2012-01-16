# encoding: utf-8
require 'spec_helper'

describe Skiima::Base do
  subject { Skiima::Base.new }

  describe "#read_config" do
    let(:config_file) { File.join(SKIIMA_ROOT, 'config/skiima.yml') }
    let(:empty_config_file) { File.join(SKIIMA_ROOT, 'config/empty_skiima.yml') }
    let(:no_config_file) { File.join(SKIIMA_ROOT, 'db/skiima/not_there.yml') }

    it 'sets the config options' do
      config = subject.send(:read_config_file, config_file)
      config['load_order'].must_equal 'sequential'
      config['logging_out'].must_equal '$stdout'
      config['logging_level'].wont_be_nil
    end

    it 'returns an empty hash if config file is empty' do
      empty_config = subject.send(:read_config_file, empty_config_file)
      empty_config.must_equal({})
    end

    it 'raises exception if config file can not be found' do
      proc { subject.send(:read_config_file, no_config_file) }.must_raise(Skiima::MissingFileException)
    end
  end

  describe "#read_options" do
    let(:depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/depends.yml') }
    let(:empty_depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/empty_depends.yml') }
    let(:no_depends_file) { File.join(SKIIMA_ROOT, 'db/skiima/not_there.yml') }

    it 'sets an ordered array for each set of sql objects' do
      depends = subject.send(:read_depends_file, depends_file)
      depends['friends'].keys.must_include('view_friends', 'rule_view_friends_delete')
    end

    it 'sets an empty array if there are no sql objects for a set' do
      empty_depends_set = subject.send(:read_depends_file, depends_file)
      empty_depends_set['team_members'].must_be_nil
    end

    it 'returns an empty hash if there are no sets of sql objects' do
      empty_depends = subject.send(:read_depends_file, empty_depends_file)
      empty_depends.must_equal({})
    end

    it 'raises exception if depends file can not be found' do
      proc { subject.send(:read_depends_file, no_depends_file) }.must_raise(Skiima::MissingFileException)
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
      ski_too = Skiima.new(:database_config_file => 'postgresql.yml')
      ski_too.database_config_file.must_equal File.join(SKIIMA_ROOT, 'config', 'postgresql.yml')
    end

    it "overrides module defaults with skiima.yml" do
      subject.logging_level.must_equal 9
    end
  end
end






__END__


      #
      #Skiima.project_root.must_equal SKIIMA_ROOT
      #Skiima.project_config_path.must_equal project_config_path
      #Skiima.config_file.must_equal skiima_yml_file
      #Skiima.database_config_file.must_equal db_config_file
      #
      #Skiima.skiima_path.must_equal skiima_path
      #Skiima.depends_file.must_equal depends_file