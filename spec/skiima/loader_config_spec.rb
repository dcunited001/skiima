# encoding: utf-8
require 'spec_helper'

describe Skiima::LoaderConfig do
  subject { Skiima::LoaderConfig }

  before do
    @loader_config = Skiima::LoaderConfig.new(
      :locale => Skiima.locale_file,
      :config => Skiima.config_file,
      :depends => Skiima.depends_file)
  end

  it 'sets the locale' do

  end

  it 'sets the config' do

  end

  it 'sets the dependencies' do

  end
end