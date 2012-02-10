# encoding: utf-8
require 'spec_helper'

describe Skiima::Logger do
  let(:std_logger) { Skiima::Logger.new(9) }

  let(:out_file) { File.join(Skiima.project_root, 'test.log') }
  let(:file_logger) { Skiima::Logger.new(9, out_file) }

  describe "#new" do
    it 'should create a logger that can print to stdout' do
      std_logger.out.must_equal "$stdout"
    end

    it 'should create a logger that can print to a file' do
      file_logger.out.must_equal out_file
    end
  end
end

