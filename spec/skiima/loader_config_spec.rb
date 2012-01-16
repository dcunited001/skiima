# encoding: utf-8
require 'spec_helper'

describe Skiima::LoaderConfig do
  subject { Skiima::LoaderConfig }

  before do
    @loader_config = Skiima::LoaderConfig.new(:config => File.join(SKIIMA_ROOT, 'config/skiima.yml'))
  end

  it 'sets the config options' do
    @loader_config.config['load_order'].must_equal 'sequential'
    @loader_config.config['logging_level'].wont_be_nil
  end

  it 'sets the dependencies' do

  end
end
